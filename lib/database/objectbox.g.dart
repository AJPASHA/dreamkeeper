// GENERATED CODE - DO NOT MODIFY BY HAND
// This code was generated by ObjectBox. To update it run the generator again
// with `dart run build_runner build`.
// See also https://docs.objectbox.io/getting-started#generate-objectbox-code

// ignore_for_file: camel_case_types, depend_on_referenced_packages
// coverage:ignore-file

import 'dart:typed_data';

import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'
    as obx_int; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart' as obx;
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import '../database/model.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <obx_int.ModelEntity>[
  obx_int.ModelEntity(
      id: const obx_int.IdUid(2, 8498441547869950965),
      name: 'DocumentBlock',
      lastPropertyId: const obx_int.IdUid(7, 932829881909351894),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 4695830043673354858),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 3312115277807237450),
            name: 'documentId',
            type: 11,
            flags: 520,
            indexId: const obx_int.IdUid(4, 3900456191496689384),
            relationTarget: 'DreamkeeperDocument'),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 4016104214674083446),
            name: 'content',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(7, 932829881909351894),
            name: 'vector',
            type: 28,
            flags: 8,
            indexId: const obx_int.IdUid(9, 2709633154347540740),
            hnswParams: obx_int.ModelHnswParams(
              dimensions: 1024,
            ))
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(3, 6764158569011806594),
      name: 'DreamkeeperDocument',
      lastPropertyId: const obx_int.IdUid(5, 3801252166603286614),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 598647620695673948),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 1017246104261213401),
            name: 'content',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 3312271517109488441),
            name: 'createdOn',
            type: 10,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 5044171483683226317),
            name: 'editedOn',
            type: 10,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 3801252166603286614),
            name: 'title',
            type: 9,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[
        obx_int.ModelRelation(
            id: const obx_int.IdUid(2, 1968626357904876502),
            name: 'feeds',
            targetId: const obx_int.IdUid(4, 3826825930516348685))
      ],
      backlinks: <obx_int.ModelBacklink>[
        obx_int.ModelBacklink(
            name: 'blocks', srcEntity: 'DocumentBlock', srcField: 'document')
      ]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(4, 3826825930516348685),
      name: 'Feed',
      lastPropertyId: const obx_int.IdUid(4, 269136504675719333),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 4866845358497182939),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 8008015293864977768),
            name: 'title',
            type: 9,
            flags: 2080,
            indexId: const obx_int.IdUid(6, 8435591058763689579)),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 8347278870141894428),
            name: 'deletable',
            type: 1,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 269136504675719333),
            name: 'lastViewed',
            type: 10,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[
        obx_int.ModelRelation(
            id: const obx_int.IdUid(3, 7927619773142596319),
            name: 'documents',
            targetId: const obx_int.IdUid(3, 6764158569011806594))
      ],
      backlinks: <obx_int.ModelBacklink>[])
];

/// Shortcut for [obx.Store.new] that passes [getObjectBoxModel] and for Flutter
/// apps by default a [directory] using `defaultStoreDirectory()` from the
/// ObjectBox Flutter library.
///
/// Note: for desktop apps it is recommended to specify a unique [directory].
///
/// See [obx.Store.new] for an explanation of all parameters.
///
/// For Flutter apps, also calls `loadObjectBoxLibraryAndroidCompat()` from
/// the ObjectBox Flutter library to fix loading the native ObjectBox library
/// on Android 6 and older.
Future<obx.Store> openStore(
    {String? directory,
    int? maxDBSizeInKB,
    int? maxDataSizeInKB,
    int? fileMode,
    int? maxReaders,
    bool queriesCaseSensitiveDefault = true,
    String? macosApplicationGroup}) async {
  await loadObjectBoxLibraryAndroidCompat();
  return obx.Store(getObjectBoxModel(),
      directory: directory ?? (await defaultStoreDirectory()).path,
      maxDBSizeInKB: maxDBSizeInKB,
      maxDataSizeInKB: maxDataSizeInKB,
      fileMode: fileMode,
      maxReaders: maxReaders,
      queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
      macosApplicationGroup: macosApplicationGroup);
}

/// Returns the ObjectBox model definition for this project for use with
/// [obx.Store.new].
obx_int.ModelDefinition getObjectBoxModel() {
  final model = obx_int.ModelInfo(
      entities: _entities,
      lastEntityId: const obx_int.IdUid(5, 4268591203767669145),
      lastIndexId: const obx_int.IdUid(9, 2709633154347540740),
      lastRelationId: const obx_int.IdUid(3, 7927619773142596319),
      lastSequenceId: const obx_int.IdUid(0, 0),
      retiredEntityUids: const [869866442667580768, 4268591203767669145],
      retiredIndexUids: const [6115012636440699710],
      retiredPropertyUids: const [
        7038815928080113058,
        5245210910484295520,
        8186406677713977854,
        6603946342748197489,
        6144097006031577889,
        1320742463321956039,
        7768266513124934083,
        6846171265697844033,
        3081139390239739271,
        8278152135356203481,
        1896977186017631673,
        4463150412622381682,
        5299147988217474860
      ],
      retiredRelationUids: const [5080214140499351460],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, obx_int.EntityDefinition>{
    DocumentBlock: obx_int.EntityDefinition<DocumentBlock>(
        model: _entities[0],
        toOneRelations: (DocumentBlock object) => [object.document],
        toManyRelations: (DocumentBlock object) => {},
        getId: (DocumentBlock object) => object.id,
        setId: (DocumentBlock object, int id) {
          object.id = id;
        },
        objectToFB: (DocumentBlock object, fb.Builder fbb) {
          final contentOffset = fbb.writeString(object.content);
          final vectorOffset = object.vector == null
              ? null
              : fbb.writeListFloat32(object.vector!);
          fbb.startTable(8);
          fbb.addInt64(0, object.id);
          fbb.addInt64(3, object.document.targetId);
          fbb.addOffset(5, contentOffset);
          fbb.addOffset(6, vectorOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final contentParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 14, '');
          final vectorParam =
              const fb.ListReader<double>(fb.Float32Reader(), lazy: false)
                  .vTableGetNullable(buffer, rootOffset, 16);
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final object =
              DocumentBlock(contentParam, vector: vectorParam, id: idParam);
          object.document.targetId =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 10, 0);
          object.document.attach(store);
          return object;
        }),
    DreamkeeperDocument: obx_int.EntityDefinition<DreamkeeperDocument>(
        model: _entities[1],
        toOneRelations: (DreamkeeperDocument object) => [],
        toManyRelations: (DreamkeeperDocument object) => {
              obx_int.RelInfo<DreamkeeperDocument>.toMany(2, object.id):
                  object.feeds,
              obx_int.RelInfo<DocumentBlock>.toOneBacklink(4, object.id,
                      (DocumentBlock srcObject) => srcObject.document):
                  object.blocks
            },
        getId: (DreamkeeperDocument object) => object.id,
        setId: (DreamkeeperDocument object, int id) {
          object.id = id;
        },
        objectToFB: (DreamkeeperDocument object, fb.Builder fbb) {
          final contentOffset = fbb.writeString(object.content);
          final titleOffset =
              object.title == null ? null : fbb.writeString(object.title!);
          fbb.startTable(6);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, contentOffset);
          fbb.addInt64(2, object.createdOn.millisecondsSinceEpoch);
          fbb.addInt64(3, object.editedOn.millisecondsSinceEpoch);
          fbb.addOffset(4, titleOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final contentParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 6, '');
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final titleParam = const fb.StringReader(asciiOptimization: true)
              .vTableGetNullable(buffer, rootOffset, 12);
          final createdOnParam = DateTime.fromMillisecondsSinceEpoch(
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 8, 0));
          final editedOnParam = DateTime.fromMillisecondsSinceEpoch(
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 10, 0));
          final object = DreamkeeperDocument(contentParam,
              id: idParam,
              title: titleParam,
              createdOn: createdOnParam,
              editedOn: editedOnParam);
          obx_int.InternalToManyAccess.setRelInfo<DreamkeeperDocument>(
              object.feeds,
              store,
              obx_int.RelInfo<DreamkeeperDocument>.toMany(2, object.id));
          obx_int.InternalToManyAccess.setRelInfo<DreamkeeperDocument>(
              object.blocks,
              store,
              obx_int.RelInfo<DocumentBlock>.toOneBacklink(4, object.id,
                  (DocumentBlock srcObject) => srcObject.document));
          return object;
        }),
    Feed: obx_int.EntityDefinition<Feed>(
        model: _entities[2],
        toOneRelations: (Feed object) => [],
        toManyRelations: (Feed object) =>
            {obx_int.RelInfo<Feed>.toMany(3, object.id): object.documents},
        getId: (Feed object) => object.id,
        setId: (Feed object, int id) {
          object.id = id;
        },
        objectToFB: (Feed object, fb.Builder fbb) {
          final titleOffset = fbb.writeString(object.title);
          fbb.startTable(5);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, titleOffset);
          fbb.addBool(2, object.deletable);
          fbb.addInt64(3, object.lastViewed?.millisecondsSinceEpoch);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final lastViewedValue =
              const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 10);
          final titleParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 6, '');
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final deletableParam =
              const fb.BoolReader().vTableGet(buffer, rootOffset, 8, false);
          final lastViewedParam = lastViewedValue == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(lastViewedValue);
          final object = Feed(titleParam,
              id: idParam,
              deletable: deletableParam,
              lastViewed: lastViewedParam);
          obx_int.InternalToManyAccess.setRelInfo<Feed>(object.documents, store,
              obx_int.RelInfo<Feed>.toMany(3, object.id));
          return object;
        })
  };

  return obx_int.ModelDefinition(model, bindings);
}

/// [DocumentBlock] entity fields to define ObjectBox queries.
class DocumentBlock_ {
  /// See [DocumentBlock.id].
  static final id =
      obx.QueryIntegerProperty<DocumentBlock>(_entities[0].properties[0]);

  /// See [DocumentBlock.document].
  static final document =
      obx.QueryRelationToOne<DocumentBlock, DreamkeeperDocument>(
          _entities[0].properties[1]);

  /// See [DocumentBlock.content].
  static final content =
      obx.QueryStringProperty<DocumentBlock>(_entities[0].properties[2]);

  /// See [DocumentBlock.vector].
  static final vector =
      obx.QueryHnswProperty<DocumentBlock>(_entities[0].properties[3]);
}

/// [DreamkeeperDocument] entity fields to define ObjectBox queries.
class DreamkeeperDocument_ {
  /// See [DreamkeeperDocument.id].
  static final id =
      obx.QueryIntegerProperty<DreamkeeperDocument>(_entities[1].properties[0]);

  /// See [DreamkeeperDocument.content].
  static final content =
      obx.QueryStringProperty<DreamkeeperDocument>(_entities[1].properties[1]);

  /// See [DreamkeeperDocument.createdOn].
  static final createdOn =
      obx.QueryDateProperty<DreamkeeperDocument>(_entities[1].properties[2]);

  /// See [DreamkeeperDocument.editedOn].
  static final editedOn =
      obx.QueryDateProperty<DreamkeeperDocument>(_entities[1].properties[3]);

  /// See [DreamkeeperDocument.title].
  static final title =
      obx.QueryStringProperty<DreamkeeperDocument>(_entities[1].properties[4]);

  /// see [DreamkeeperDocument.feeds]
  static final feeds = obx.QueryRelationToMany<DreamkeeperDocument, Feed>(
      _entities[1].relations[0]);

  /// see [DreamkeeperDocument.blocks]
  static final blocks =
      obx.QueryBacklinkToMany<DocumentBlock, DreamkeeperDocument>(
          DocumentBlock_.document);
}

/// [Feed] entity fields to define ObjectBox queries.
class Feed_ {
  /// See [Feed.id].
  static final id = obx.QueryIntegerProperty<Feed>(_entities[2].properties[0]);

  /// See [Feed.title].
  static final title =
      obx.QueryStringProperty<Feed>(_entities[2].properties[1]);

  /// See [Feed.deletable].
  static final deletable =
      obx.QueryBooleanProperty<Feed>(_entities[2].properties[2]);

  /// See [Feed.lastViewed].
  static final lastViewed =
      obx.QueryDateProperty<Feed>(_entities[2].properties[3]);

  /// see [Feed.documents]
  static final documents = obx.QueryRelationToMany<Feed, DreamkeeperDocument>(
      _entities[2].relations[0]);
}
