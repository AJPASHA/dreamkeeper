import 'dart:convert';
import 'package:objectbox/objectbox.dart';

/* Objectbox data model for business logic

  Entities:
    Feed: A named list of documents 
    FeedEntry: A wrapper for the document in a feed which tells us when it was system recommended (if null then it was user generated), 
      and when the user blacklisted it as irrelevant (if null then it should remain visible in the UI)
    Document: The contents of a document
    DocumentBlock: blocks of the document of an appropriate size for the embedding (stored as a reference to a subset of the document)
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

  @Backlink('entries')
  final blocks = ToMany<DocumentBlock>();
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
  String? title; // by default titles don't have to have names

  DateTime createdOn;
  DateTime editedOn;

  DreamkeeperDocument( this.content, {this.id=0, this.title, DateTime? createdOn, DateTime? editedOn, }) 
    : createdOn = createdOn ?? DateTime.now(),
      editedOn = editedOn ?? DateTime.now();


  /// get the content of the document in a form that it can be manipulated, e.g. for blocks 
  List<Map<String, dynamic>> get contentMap {
    return List<Map<String, dynamic>>.from(jsonDecode(content));
  }


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
  /// - [content]: The content of the subdocument.
  /// - [vector]: The Vector index of the document
  /// 
  /// Getters:
  /// - [richtext]: get a map of the quill document for 
  /// - [plaintext]: get the plaintext content of the block 
  /// Relationships:
  /// - [document]: A reference to the Document that this block belongs to.
  /// - [embedding]: A reference to the BlockVector representing the embedding of this block.
  @Id()
  int id;
  String content;
  @HnswIndex(dimensions: 1024) @Property(type: PropertyType.floatVector)
  List<double>? vector;

  String get plaintext {
    return jsonDecode(content).map((e) => e['insert']).join("");
  }

  DocumentBlock(this.content, {this.vector,this.id=0});

  final document = ToOne<DreamkeeperDocument>();



  final entries = ToMany<FeedEntry>();
}

// // TODO: change the length of the embedding field based on size of model being used
// @Entity()
// class BlockVector {
//   /// Represents the embedding of a document block.
//   /// 
//   /// Properties:
//   /// - [id]: Unique identifier for the block vector.
//   /// - [vector]: A list of floating-point numbers representing the embedding.
//   /// 
//   /// Relationships:
//   /// - [document]: A reference to the Document that this block vector is associated with.
//   /// - [block]: A reference to the DocumentBlock that this block vector is associated with.
//   @Id() int id;


//   BlockVector(this.vector, {this.id=0});

//   final document = ToOne<DreamkeeperDocument>();
//   final block = ToOne<DocumentBlock>();
// }
