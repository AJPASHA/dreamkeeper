import 'package:objectbox/objectbox.dart';

/* Objectbox data model for business logic

  Entities:
    Feed: A named list of documents 
    FeedEntry: A wrapper for the document in a feed which tells us when it was system recommended (if null then it was user generated), 
      and when the user blacklisted it as irrelevant (if null then it should remain visible in the UI)
    Document: The contents of a document
    DocumentBlock: PlainText blocks of text extracted from the contents of the document
    BlockVector: The Embedding

*/


@Entity()
class Feed {
  /// Represents a named list of documents.
  /// 
  /// Properties:
  /// - [id]: Unique identifier for the feed.
  /// - [title]: The name of the feed.
  /// 
  /// Relationships:
  /// - [entries]: A list of FeedEntry objects associated with this feed.
  @Id() int id;
  @Unique() String title;
  bool deletable; // some feeds should never be deleted such as the 'everything feed'
  DateTime? lastViewed; // This gives a property for ordering by

  Feed(this.title, {this.id=0, this.deletable = true, this.lastViewed}); // id=0 is a special value, which assigns the object to the first available idx

  // final documents = ToMany<Document>();
  @Backlink('feed')
  final entries = ToMany<FeedEntry>();

}

@Entity()
class FeedEntry {
  /// Represents a document entry in a feed. This acts as a neat wrapper for document which allows us to store recommendation metadata
  /// 
  /// Properties:
  /// - [id]: Unique identifier for the feed entry.
  /// - [dateRecommendedToUser]: The date when the document was recommended to the user.
  /// - [dateBlacklistedByUser]: The date when the user blacklisted the document.
  /// 
  /// Relationships:
  /// - [feed]: A reference to the Feed that this entry belongs to.
  /// - [document]: a reference to the document that this entry represents
  @Id()
  int id;
  DateTime? dateRecommendedToUser;
  DateTime? dateBlacklistedByUser;
  FeedEntry({this.id=0, this.dateRecommendedToUser, this.dateBlacklistedByUser});
  

  final feed = ToOne<Feed>();
  final document = ToOne<DreamkeeperDocument>();
}

@Entity()
class DreamkeeperDocument {
  /// Represents the contents of a document.
  /// 
  /// Properties:
  /// - [id]: Unique identifier for the document.
  /// - [content]: The text content of the document.
  /// - [createdOn]: The date when the document was created.
  /// - [editedOn]: The date when the document was last edited.
  /// 
  /// Relationships:
  /// - [entries]: A list of FeedEntry objects associated with this document.
  /// - [blocks]: A list of DocumentBlock objects extracted from this document.
  @Id()
  int id;
  String content;

  DateTime createdOn;
  DateTime editedOn;

  DreamkeeperDocument( this.content, {this.id=0, DateTime? createdOn, DateTime? editedOn}) 
    : createdOn = createdOn ?? DateTime.now(),
      editedOn = editedOn ?? DateTime.now();

  @Backlink('document')
  final entries = ToMany<FeedEntry>();

  @Backlink('document')
  final blocks = ToMany<DocumentBlock>();
}


@Entity()
class DocumentBlock {
  /// Represents a block of plain text extracted from a document.
  /// 
  /// Properties:
  /// - [id]: Unique identifier for the document block.
  /// - [blockNumber]: The starting line number of the block in the document.
  /// - [plaintext]: The text content of the block.
  /// 
  /// Relationships:
  /// - [document]: A reference to the Document that this block belongs to.
  /// - [embedding]: A reference to the BlockVector representing the embedding of this block.
  @Id()
  int id;
  int blockNumber; // The location of the block in the quill delta document
  String plaintext;

  DocumentBlock(this.blockNumber, this.plaintext, {this.id=0});

  final document = ToOne<DreamkeeperDocument>();
  final embedding = ToOne<BlockVector>();

}

// TODO: change the length of the embedding field based on size of model being used
@Entity()
class BlockVector {
  /// Represents the embedding of a document block.
  /// 
  /// Properties:
  /// - [id]: Unique identifier for the block vector.
  /// - [vector]: A list of floating-point numbers representing the embedding.
  /// 
  /// Relationships:
  /// - [document]: A reference to the Document that this block vector is associated with.
  /// - [block]: A reference to the DocumentBlock that this block vector is associated with.
  @Id() int id;

  // @HnswIndex(dimensions: 512) @Property(type: PropertyType.floatVector)
  // List<double> vector;

  BlockVector({this.id=0});
  // BlockVector(this.vector, {this.id=0});

  final document = ToOne<DreamkeeperDocument>();
  final block = ToOne<DocumentBlock>();
}
