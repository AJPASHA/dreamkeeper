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

    //TODO: implement demo HNSW Vector values

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
    FeedEntry entry = FeedEntry(dateRecommendedToUser: (systemRecommended ?? false) ? DateTime.now() : null);
    entry.document.targetId = documentId;
    entry.feed.targetId = feedId;

    return feedEntryBox.put(entry);
  }

  /// Generate embeddings for a list of document blocks
  Future<List<DocumentBlock>> generateEmbeddings(List<DocumentBlock> blocks) async {
    final List<String> texts = blocks.map((e) => e.plaintext).toList();
    final EmbeddingResponse response = await embeddingService.getEmbeddings(texts, EmbeddingPassageType.passage) as EmbeddingResponse; // force cast as errors should occur in API service code
    final embeddings = response.embeddings;
    for (final i in List.generate(blocks.length, (i) => i, growable: false)) {
      final embedding = BlockVector(embeddings[i]);
      embedding.block.target = blocks[i];
      blocks[i].embedding.target = embedding;
    }
    // for (var e in blocks) {
    //   debugPrint("${e.embedding.target?.vector}");
    // }

    blockBox.putManyAsync(blocks); // don't think we need to await this, can happen in it's own time
    return blocks;
  }

  // entities representing document metadata (blocks, vectors) are abstracted away from the API so we don't have public setters or getters for them

  /* Read */

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
    final builder = blockBox.query(DocumentBlock_.embedding.isNull());
    return builder.build().find();
  }

  /* Update */

  /// Save a document
  void saveDocument(DreamkeeperDocument document) {
    // TODO: Make this Async?
    

    //Since objectbox does not seem to handle cascading deletes, we handle deletes to the blocks within a trx
    store.runInTransaction(TxMode.write, () {
      // blockBox.removeMany(ids)
      blockBox.query(DocumentBlock_.document.equals(document.id)).build().remove();
      List<DocumentBlock> blocks = _getBlocksFromDocument(document);
      document.blocks.addAll(blocks);

      // scan for missing vectors

      documentBox.put(document);

      generateEmbeddings(blocks); // this might want to be async

    });
    
    debugPrint("Document Saved!");
  }

  /* Delete */

  /// Delete a document based on its id
  void deleteDocument(int id) {
    store.runInTransaction(TxMode.write, () {
      blockBox.query(DocumentBlock_.document.equals(id)).build().remove();
      blockVectorBox.query(BlockVector_.document.equals(id)).build().remove();
      feedEntryBox.query(FeedEntry_.document.equals(id)).build().remove();
      documentBox.remove(id);
      // TODO: insert vector delete operations
    });
  }


  /*** Utils ***/

  /// Get a list of plaintext blocks from a document, by default, these have an overlap and a minimum preferred size. 
  /// This ensures that the vectors generated from the blocks are long enough to be meaningful (except where the user hasn't written a coherent thought down)
  /// This also means that document blocks are not mutually exclusive from one another and are not commutative 'building blocks' from which you can rebuild a doc
  List<DocumentBlock> _getBlocksFromDocument(DreamkeeperDocument document) {
    // TODO: alter this so that it generates blocks that are less than the max token count for the embedding model 512*(3/4)= 384 words long
    // TODO: add minimum length and standard overlap arguments, this ensures that where we have a sequence that is slightly over the limit, we don't get stubs

    List<dynamic> components = jsonDecode(document.content);

    List<DocumentBlock> blocks = [];
    int blockNumber = 0;
    for (var component in components) {
      if (component is Map<String, dynamic>) {
        String? plaintext =
            component.containsKey('insert') ? component['insert'] : null;

        if (plaintext != null) {
          blocks.add(DocumentBlock(blockNumber, plaintext));
        } // no point adding empty blocks to the db, that would just waste space
      }
    }
    return blocks;
  }

}
