import 'dart:convert';
import 'dart:math';
import 'package:dreamkeeper/services/text_embedding_service.dart';
import 'package:flutter/material.dart';

import 'objectbox.g.dart';
import 'model.dart';

TextEmbeddingService embeddingService = TextEmbeddingService();

class ObjectBox {
  late final Store store;

  late final Box<Feed> feedBox;
  late final Box<DreamkeeperDocument> documentBox;
  late final Box<DocumentBlock> blockBox;

  static Future<ObjectBox> create() async {
    final store = await openStore();
    return ObjectBox._create(store);
  }

  ObjectBox._create(this.store) {
    feedBox = Box<Feed>(store);
    documentBox = Box<DreamkeeperDocument>(store);
    blockBox = Box<DocumentBlock>(store);

    if (documentBox.isEmpty()) {
      _putDemoData();
    } // TODO: comment this out before going into prod

    
  }
  //TODO: Create initial data generation function for prod
  void _putDemoData() {
    // Nuclear Option: delete the model file and rerun build_runner
    Feed feed1 = Feed("Demo Feed");

    DreamkeeperDocument document1 = DreamkeeperDocument(
        r'[{"insert":"Demo File"},{"insert":"\n","attributes":{"header":1}},{"insert":"\nLorum Ipsum dolor est.\n\nThis is a list"},{"insert":"\n","attributes":{"list":"ordered"}},{"insert":"This is a list inside a list"},{"insert":"\n","attributes":{"list":"ordered","indent":1}},{"insert":"This is a checkbox"},{"insert":"\n","attributes":{"list":"unchecked"}},{"insert":"This is a ticked checkbox"},{"insert":"\n","attributes":{"list":"checked"}},{"insert":"This is a ticked checkbox within a checkbox "},{"insert":"\n","attributes":{"list":"checked","indent":1}},{"insert":"\n"}]');
    document1.blocks.addAll(_getBlocksFromDocument(document1));

    feedBox.put(feed1);
  }


  /////////////////////////
  /* Document operations */
  /////////////////////////
  
  /// Create a document and return its id in the database
  int createDocument() => documentBox.put(DreamkeeperDocument(""));

  DreamkeeperDocument createAndGetDocument() {
    final int docId = createDocument();
    return documentBox.get(docId)!;
  }

  /// Get a document based on its id
  DreamkeeperDocument? getDocument(int id) => documentBox.get(id);


 /// Save a document
  void saveDocument(DreamkeeperDocument document) async {
    // debugPrint("Title of document: ${document.title}");

    //Since objectbox does not seem to handle cascading deletes, we handle deletes to the blocks within a trx
    store.runInTransaction(TxMode.write, () {

      // TODO: make this a lot more efficient (cost-wise) by only replacing those blocks which have actually changed content
      // TODO: Create a block refresh operation that handles this.
      blockBox
          .query(DocumentBlock_.document.equals(document.id))
          .build()
          .remove();
      List<DocumentBlock> blocks = _getBlocksFromDocument(document);
      document.blocks.addAll(blocks);
      document.editedOn = DateTime.now();
      documentBox.put(document);
      _refreshVectorIndex();
    });


    debugPrint("Document Saved!");
  }

  /// Delete a document based on its id
  void deleteDocument(int id) {
    if (id==0) { return; } // 0 means that this doc hasn't been saved before, so we can't delete it
    if (!documentBox.contains(id)) {return;}
    store.runInTransaction(TxMode.write, () {
      blockBox.query(DocumentBlock_.document.equals(id)).build().remove();
      documentBox.remove(id);
    });
  }


  List<DocumentBlock> _getBlocksFromDocument(DreamkeeperDocument document) {
    const maxsize = 128;
    const minsplit = 32;


    List<Map<String, dynamic>> components =
        List<Map<String, dynamic>>.from(jsonDecode(document.content));


    /* step one, split larger blocks into smaller chunks */

    // dynamically get the wordcounts
    List<int> wordcounts() => components
        .map((e) => e['insert'] as String)
        .map((e) => e.split(" ").length)
        .toList();

    List<int> counts = wordcounts();
 

    // TODO: make this smarter by first looking for a whitespace character to split on before going for generic split
    // break components into chunks until they get small enough
    while (counts.fold(0, max) > maxsize) {
      int indexToChunk = counts.indexWhere((len) => len > maxsize);

      String fullText = components[indexToChunk]['insert'];
      List<String> words = fullText.split(" ");

      // Join words back together for left and right chunks

      // if the right chunk would end up being a stub, we split in the middle instead
      int splicePoint = counts[indexToChunk] < maxsize + minsplit
          ? counts[indexToChunk] ~/ 2
          : maxsize;

      String leftText = words.take(splicePoint).join(" ");
      String rightText = words.skip(splicePoint).join(" ");
      
      // Create new component objects (not references to the original)
      Map<String, dynamic> left = Map<String, dynamic>.from(components[indexToChunk]);
      Map<String, dynamic> right = Map<String, dynamic>.from(components[indexToChunk]);
      left['insert'] = leftText;
      right['insert'] = rightText;

      // perform the chunking
      components.removeAt(indexToChunk);
      components.insertAll(indexToChunk, [left, right]);
      // components.replaceRange(indexToChunk, indexToChunk, [left, right]);
      counts = wordcounts();
      debugPrint("$counts");
    }

    /* Step 2: define subdocument split points */
    // to make this considerably cheaper, we can use the counts list to handle this
    List<List<int>> subdocumentIndices = [];
    int slowpointer = 0;
    int fastpointer = 0;
    int words = 0;
    while (slowpointer < counts.length) {
      words += counts[fastpointer];
      fastpointer += 1;

      if (words > maxsize || fastpointer == counts.length) {
        subdocumentIndices.add([slowpointer, fastpointer]);
        slowpointer = fastpointer;
        words = 0;
      }
    }

    /* Step 3: generate a list of block objects based on the indices given */

    List<String> blockstrings = subdocumentIndices
        .map((e) => jsonEncode(components.sublist(e[0], e[1])))
        .toList();

    return blockstrings.map((e) => DocumentBlock(e)).toList();
  }


  /////////////////////////////
  /* Block Vector Operations */
  /////////////////////////////
  
  /// Perform a nearest neighbours search through the vector index to return a list of document blocks wrapped with their scores
  Future<List<DocumentBlock>> searchBlockVectors(String query) async {
    if (query.split(" ").length < 3) {
      query = "Tell me about $query";
    } // this makes the index a lot better with keyword searches and short queries!

    final EmbeddingResponse? res = await embeddingService
        .getEmbeddings([query], EmbeddingPassageType.query);

    final List<double> queryEmbedding = res!.embeddings[
        0]; // forcing this because errors should be caught in service code TODO: in prod probably want something softer!
    final vectorsWithScores = blockBox
        .query(DocumentBlock_.vector.nearestNeighborsF32(queryEmbedding, 100))
        .build()
        .findWithScores(); // docs say we must find with scores to get right order
    final List<DocumentBlock> vectors =
        vectorsWithScores.map((e) => e.object).toList();


    return vectors;
  }

  
  /// Generate embeddings for a list of document blocks
  Future<List<DocumentBlock>> _generateEmbeddings(
      List<DocumentBlock> blocks) async {
    if (blocks.isEmpty) { return []; } // don't want to call API with empty List

    final List<String> texts = blocks.map((e) => e.plaintext).toList();
    final EmbeddingResponse response = await embeddingService.getEmbeddings(
            texts, EmbeddingPassageType.passage)
        as EmbeddingResponse; // force cast as errors should occur in API service code
    final embeddings = response.embeddings;
    for (final i in List.generate(blocks.length, (i) => i, growable: false)) {
      blocks[i].vector = embeddings[i];
    }
    blockBox.putManyAsync(blocks); // don't think we need to await this, can happen in it's own time
    return blocks;
  }
  /// Get a list of all document blocks that don't have a vector
  /// For use in updating search queries
  List<DocumentBlock> _getBlocksWithoutVectors() {
    return blockBox.query(DocumentBlock_.vector.isNull()).build().find();
  }

  /// Searches the vector index for any missing vectors and for any orphaned vectors, deletes the orphans and calls API to generate the missing ones
  void _refreshVectorIndex() async {
    List<DocumentBlock> missingVectors = _getBlocksWithoutVectors();
    // debugPrint("There are ${missingVectors.length} blocks without vectors");
    _generateEmbeddings(missingVectors);
    debugPrint("Vector index Refreshed!");
  }
  /////////////////////
  /* Feed operations */
  /////////////////////
  
  /// Create a feed and return its id in the database
  int createFeed(String title) => feedBox.put(Feed(title));

  /// add a feed entry based on the ids of the document, feed and whether the system recommeded
  void addDocumentToFeed(int documentId, int feedId, {bool? systemRecommended = false}) {
    final document = documentBox.get(documentId);
    if (document == null) { throw "Error trying to add non-existant document to feed!"; }
    final feed = feedBox.get(feedId);
    if (feed == null) { throw "Error trying to add document to non-existant feed!"; }

    document.feeds.add(feed);
    
    documentBox.put(document);

    return;
  }

  void removeDocumentFromFeed(int documentId, int feedId) {
    final document = documentBox.get(documentId);
    if (document == null) { throw "Error trying to remove non-existant document from feed!"; }
    final feed = feedBox.get(feedId);
    if (feed == null) { throw "Error trying to remove document from non-existant feed!"; }

    document.feeds.remove(feed);

    documentBox.put(document);
    return;
  }


  /// get a list of all (non-system) feeds based on id
  /// - [systemFeeds]: decide whether you want content feeds, or the user generated feeds (everything, stubs)
  Stream<List<Feed>> getFeeds({bool systemFeeds=false}) {
    final builder = feedBox.query(Feed_.deletable.equals(!systemFeeds))
      ..order(Feed_.lastViewed, flags: Order.descending)
      ..order(Feed_.deletable);
    return builder.watch(triggerImmediately: true).map((query) => query.find());
  }

  /// get a list of all entries within a feed
  Stream<List<DreamkeeperDocument>> getDocsInFeed(int feedId) {
    final builder = documentBox.query().order(DreamkeeperDocument_.editedOn, flags: Order.descending);
    builder.linkMany(DreamkeeperDocument_.feeds, Feed_.id.equals(feedId));
    return builder.watch(triggerImmediately: true).map((e) => e.find());
  }


  /// Refresh the feed containing everything
  void refreshEverythingFeed() {
    Feed? everythingFeed = feedBox
        .query(Feed_.title.equals(ProtectedFeedName.everything.name))
        .build()
        .findUnique();
    if (everythingFeed == null) {
      int everythingId = feedBox.put(Feed(ProtectedFeedName.everything.name, deletable: false));
      everythingFeed = feedBox.get(everythingId);
    }

    final documents = documentBox.getAll();
    
    for (DreamkeeperDocument document in documents) {
      document.feeds.add(everythingFeed!);
      documentBox.put(document);
    }
    return;
  }
}


///Defining a list of names that are reserved by the system
enum ProtectedFeedName{
  everything,
  stubs,
  todos,
  mentions
}
extension Name on ProtectedFeedName {
  String get name {
    switch (this) {
      case ProtectedFeedName.everything: return "Everything";
      case ProtectedFeedName.stubs: return "Stubs";
      case ProtectedFeedName.todos: return "To-Dos";
      case ProtectedFeedName.mentions: return "Mentions";
    }
  }
  static List<String> get protectedNames {
    return ProtectedFeedName.values.map((e) => e.name).toList();
  }
}