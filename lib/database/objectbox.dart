import 'dart:convert';
import 'package:dreamkeeper/services/text_embedding_service.dart';
import 'package:flutter/material.dart';

import 'objectbox.g.dart';
import 'model.dart';

TextEmbeddingService embeddingService = TextEmbeddingService();

class ObjectBox {
  late final Store store;

  late final Box<Feed> feedBox;
  late final Box<FeedEntry> feedEntryBox;
  late final Box<DreamkeeperDocument> documentBox;
  late final Box<DocumentBlock> blockBox;
  late final Box<BlockVector> blockVectorBox;

  static Future<ObjectBox> create() async {
    final store = await openStore();
    return ObjectBox._create(store);
  }

  ObjectBox._create(this.store) {
    feedBox = Box<Feed>(store);
    feedEntryBox = Box<FeedEntry>(store);
    documentBox = Box<DreamkeeperDocument>(store);
    blockBox = Box<DocumentBlock>(store);
    blockVectorBox = Box<BlockVector>(store);

    if (documentBox.isEmpty()) {
      _putDemoData();
    }
  }

  void _putDemoData() {
    // Nuclear Option: delete the model file and rerun build_runner
    Feed feed1 = Feed("Demo Feed");

    DreamkeeperDocument document1 = DreamkeeperDocument(
        r'[{"insert":"Demo File"},{"insert":"\n","attributes":{"header":1}},{"insert":"\nLorum Ipsum dolor est.\n\nThis is a list"},{"insert":"\n","attributes":{"list":"ordered"}},{"insert":"This is a list inside a list"},{"insert":"\n","attributes":{"list":"ordered","indent":1}},{"insert":"This is a checkbox"},{"insert":"\n","attributes":{"list":"unchecked"}},{"insert":"This is a ticked checkbox"},{"insert":"\n","attributes":{"list":"checked"}},{"insert":"This is a ticked checkbox within a checkbox "},{"insert":"\n","attributes":{"list":"checked","indent":1}},{"insert":"\n"}]');
    document1.blocks.addAll(_getBlocksFromDocument(document1));


    FeedEntry feedEntry = FeedEntry();
    feedEntry.document.target = document1;

    feed1.entries.add(feedEntry);

    feedBox.put(feed1);
  }

  /////////////
  /*** API ***/
  /////////////

  /* Create */

  /// Create a document and return its id in the database
  int createDocument() => documentBox.put(DreamkeeperDocument(""));

  /// Create a feed and return its id in the database
  int createFeed(String title) => feedBox.put(Feed(title));

  /// add a feed entry based on the ids of the document, feed and whether the system recommeded
  int addEntry(int documentId, int feedId, bool? systemRecommended) {
    FeedEntry entry = FeedEntry(
        dateRecommendedToUser:
            (systemRecommended ?? false) ? DateTime.now() : null);
    entry.document.targetId = documentId;
    entry.feed.targetId = feedId;

    return feedEntryBox.put(entry);
  }

  /// Generate embeddings for a list of document blocks
  Future<List<DocumentBlock>> generateEmbeddings(
      List<DocumentBlock> blocks) async {
    if (blocks.isEmpty) {
      return [];
    } // don't want to call API with empty List
    final List<String> texts = blocks.map((e) => e.plaintext).toList();
    final EmbeddingResponse response = await embeddingService.getEmbeddings(
            texts, EmbeddingPassageType.passage)
        as EmbeddingResponse; // force cast as errors should occur in API service code
    final embeddings = response.embeddings;
    for (final i in List.generate(blocks.length, (i) => i, growable: false)) {
      final embedding = BlockVector(embeddings[i]);
      embedding.block.target = blocks[i];
      blocks[i].embedding.target = embedding;
    }
    // for (var e in blocks) {
    //   debugPrint("${e.embedding.target?.vector}");
    // }

    blockBox.putManyAsync(
        blocks); // don't think we need to await this, can happen in it's own time
    return blocks;
  }

  // entities representing document metadata (blocks, vectors) are abstracted away from the API so we don't have public setters or getters for them

  /* Read */

  /// Perform a nearest neighbours search through the vector index to return a list of document blocks wrapped with their scores
  Future<List<DocumentBlock>> searchBlockVectors(String query) async {
    if (query.split(" ").length < 3) { query = "Tell me about $query";} // this makes the index a lot better with keyword searches and short queries!

    final EmbeddingResponse? res = await embeddingService
        .getEmbeddings([query], EmbeddingPassageType.query);

    final List<double> queryEmbedding = res!.embeddings[
        0]; // forcing this because errors should be caught in service code TODO: in prod probably want something softer!
    final vectorsWithScores = blockVectorBox
        .query(BlockVector_.vector.nearestNeighborsF32(queryEmbedding, 100))
        .build()
        .findWithScores(); // docs say we must find with scores to get right order
    final List<BlockVector> vectors =
        vectorsWithScores.map((e) => e.object).toList();
    // final blocks = blockBox.query(DocumentBlock_.embedding.equals()

    List<DocumentBlock> results = [];
    for (BlockVector result in vectors) {
      DocumentBlock? block  = blockBox.query(DocumentBlock_.embedding.equals(result.id)).build().findUnique();

      if (block != null) {
        results.add(block);
      }
    }
    return results;
  }

  /// Get a document based on its id
  DreamkeeperDocument? getDocument(int id) => documentBox.get(id);

  /// get a list of all feeds based on id
  Stream<List<Feed>> getFeeds() {
    final builder = feedBox.query()
      ..order(Feed_.lastViewed, flags: Order.descending)
      ..order(Feed_.deletable);
    return builder.watch(triggerImmediately: true).map((query) => query.find());
  }

  /// get a list of all entries within a feed
  Stream<List<FeedEntry>> getEntries(int feedId) {
    final builder = feedEntryBox.query(FeedEntry_.feed.equals(feedId));
    builder.link(FeedEntry_.document);
    return builder.watch(triggerImmediately: true).map((query) => query.find());
  }

  /// Get a list of all document blocks that don't have a vector
  /// For use in updating search queries
  List<DocumentBlock> getBlocksWithoutVectors() {
    return blockBox.query(DocumentBlock_.embedding.isNull()).build().find() 
        + blockBox.query(DocumentBlock_.embedding.equals(0)).build().find();
  }

  /* Update */

  /// Searches the vector index for any missing vectors and for any orphaned vectors, deletes the orphans and calls API to generate the missing ones
  void refreshVectorIndex() async {
    store.runInTransaction(TxMode.write, () {
      //remove orphans
      final List<int> orphanedVecIds = 
          blockVectorBox.query(BlockVector_.block.isNull()).build().findIds() +
          blockVectorBox.query(BlockVector_.block.equals(0)).build().findIds();
      // debugPrint("There are ${orphanedVecIds.length} vectors without blocks");
      blockVectorBox.removeMany(orphanedVecIds);
      // generate missing vectors
      final List<DocumentBlock> missingVectors = getBlocksWithoutVectors();
      // debugPrint("There are ${missingVectors.length} blocks without vectors");
      generateEmbeddings(missingVectors);
    });

    debugPrint("Vector index Refreshed!");
  }

  /// Save a document
  void saveDocument(DreamkeeperDocument document) async {
    //Since objectbox does not seem to handle cascading deletes, we handle deletes to the blocks within a trx
    store.runInTransaction(TxMode.write, () {
      // blockBox.removeMany(ids)
      blockBox
          .query(DocumentBlock_.document.equals(document.id))
          .build()
          .remove();
      List<DocumentBlock> blocks = _getBlocksFromDocument(document);
      document.blocks.addAll(blocks);

      documentBox.put(document);

      refreshVectorIndex();
    });

    debugPrint("Document Saved!");
  }

  /* Delete */

  /// Delete a document based on its id
  void deleteDocument(int id) {
    store.runInTransaction(TxMode.write, () {
      blockBox.query(DocumentBlock_.document.equals(id)).build().remove();
      blockVectorBox.query(BlockVector_.document.equals(id)).build().remove(); // TODO: Bug here when deleting empty doc
      feedEntryBox.query(FeedEntry_.document.equals(id)).build().remove();
      documentBox.remove(id);
      // TODO: insert vector delete operations
    });
  }

  /*** Utils ***/

  /// Get a list of plaintext blocks from a document, by default, these have an overlap and a minimum preferred size.
  /// This ensures that the vectors generated from the blocks are long enough to be meaningful (except where the user hasn't written a coherent thought down)
  /// This also means that document blocks are not mutually exclusive from one another and are not commutative 'building blocks' from which you can rebuild a doc
  /// default maxsize is based on the fact that max input to e5 embeddings is 512 tokens, so ~(3/4)*512=384 words. We use 350 to give ourselves some extra slack.
  List<DocumentBlock> _getBlocksFromDocument(DreamkeeperDocument document, {int overlap=8, int minsize=64, int maxsize=128}) {
    // TODO: alter this so that it generates blocks that are less than the max token count for the embedding model 512*(3/4)= 384 words long
    // TODO: add minimum length and standard overlap arguments, this ensures that where we have a sequence that is slightly over the limit, we don't get stubs

    if (overlap >= maxsize) {throw "You can't overlap more words than your max chunk size, algorithm will never complete!";}
    if (maxsize <= minsize) {throw "You can't have a longer minimum size than max chunk size. else you will get EOF errors!";}

    // turn the flutter quill document into a json-like object
    List<Map<String, dynamic>> components = List<Map<String, dynamic>>.from(jsonDecode(document.content));

    List<DocumentBlock> blocks = []; // OUTPUT
    int blockNumber = 0;


    // Special case: where the first element is a header of some kind, the second element will be an empty insert for the header styling
    // We want to store this first block seperately, to act as a header block 
    if (components[1]['insert'].length == 1) { 
      // look up flutter quill docs to see that headers are followed by an empty newline, with the header attr
      final Map<String,dynamic> headerComponent = components.removeAt(0);
      final String header = headerComponent['insert'];
      blocks.add(DocumentBlock(blockNumber, header));
      blockNumber = blockNumber + 1;

    }

    // next thing to do is generate a plaintext corpus of the rest of the document 
    // final re = RegExp(r"\s*"); // any amount of whitespace
    final List<String> words = components.map((e) => e['insert']).join("").split(" ");

    debugPrint("$words");
    debugPrint("${words.length}");
    // to make sure that the minimum size doesn't get in the way of the algorithm completing
    if (words.length < minsize) {minsize = 0;}

    // Then we run a simple chunking algorithm that reassembles the plain text into document blocks that we add to the output
    int cursor = 0;
    while (cursor < words.length) {
      cursor = cursor <= overlap ? cursor : cursor - overlap; // if the cursor has space, move it back by overlap number of words
      final int wordsRemaining = words.length - cursor; // how much of the document is left to scan

      late final String plaintext;      
      if (wordsRemaining >= maxsize) {
        plaintext = words.sublist(cursor, cursor + maxsize).join(" ");
        cursor = cursor + maxsize;

      } else if (wordsRemaining >= minsize) {
        plaintext = words.sublist(cursor).join(" ");
        cursor = cursor + words.length; // BREAK after this loop
      } else {
        cursor = words.length - minsize;
        plaintext = words.sublist(cursor).join(" ");
        cursor = words.length; // BREAK after this loop
      }

      blocks.add(DocumentBlock(blockNumber, plaintext)); // YIELD

      blockNumber = blockNumber + 1;
      debugPrint("$cursor");

    } 
    return blocks;
  }
}
