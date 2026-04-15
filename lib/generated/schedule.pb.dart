// This is a generated file - do not edit.
//
// Generated from schedule.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Empty extends $pb.GeneratedMessage {
  factory Empty() => create();

  Empty._();

  factory Empty.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Empty.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Empty',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'schedule'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Empty clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Empty copyWith(void Function(Empty) updates) =>
      super.copyWith((message) => updates(message as Empty)) as Empty;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Empty create() => Empty._();
  @$core.override
  Empty createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Empty getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Empty>(create);
  static Empty? _defaultInstance;
}

class Faculty extends $pb.GeneratedMessage {
  factory Faculty({
    $core.int? id,
    $core.String? name,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    return result;
  }

  Faculty._();

  factory Faculty.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Faculty.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Faculty',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'schedule'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Faculty clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Faculty copyWith(void Function(Faculty) updates) =>
      super.copyWith((message) => updates(message as Faculty)) as Faculty;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Faculty create() => Faculty._();
  @$core.override
  Faculty createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Faculty getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Faculty>(create);
  static Faculty? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);
}

class Group extends $pb.GeneratedMessage {
  factory Group({
    $core.int? id,
    $core.String? name,
    $core.int? facultyId,
    $core.int? eduFormId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (facultyId != null) result.facultyId = facultyId;
    if (eduFormId != null) result.eduFormId = eduFormId;
    return result;
  }

  Group._();

  factory Group.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Group.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Group',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'schedule'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aI(3, _omitFieldNames ? '' : 'facultyId')
    ..aI(4, _omitFieldNames ? '' : 'eduFormId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Group clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Group copyWith(void Function(Group) updates) =>
      super.copyWith((message) => updates(message as Group)) as Group;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Group create() => Group._();
  @$core.override
  Group createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Group getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Group>(create);
  static Group? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get facultyId => $_getIZ(2);
  @$pb.TagNumber(3)
  set facultyId($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFacultyId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFacultyId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get eduFormId => $_getIZ(3);
  @$pb.TagNumber(4)
  set eduFormId($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEduFormId() => $_has(3);
  @$pb.TagNumber(4)
  void clearEduFormId() => $_clearField(4);
}

class ScheduleItem extends $pb.GeneratedMessage {
  factory ScheduleItem({
    $core.int? id,
    $core.int? groupId,
    $core.int? dayOfWeek,
    $core.String? subject,
    $core.String? teacher,
    $core.String? room,
    $core.String? startTime,
    $core.String? endTime,
    $core.String? mode,
    $core.String? subgroup,
    $core.String? lessonType,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (groupId != null) result.groupId = groupId;
    if (dayOfWeek != null) result.dayOfWeek = dayOfWeek;
    if (subject != null) result.subject = subject;
    if (teacher != null) result.teacher = teacher;
    if (room != null) result.room = room;
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    if (mode != null) result.mode = mode;
    if (subgroup != null) result.subgroup = subgroup;
    if (lessonType != null) result.lessonType = lessonType;
    return result;
  }

  ScheduleItem._();

  factory ScheduleItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScheduleItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScheduleItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'schedule'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'groupId')
    ..aI(3, _omitFieldNames ? '' : 'dayOfWeek')
    ..aOS(4, _omitFieldNames ? '' : 'subject')
    ..aOS(5, _omitFieldNames ? '' : 'teacher')
    ..aOS(6, _omitFieldNames ? '' : 'room')
    ..aOS(7, _omitFieldNames ? '' : 'startTime')
    ..aOS(8, _omitFieldNames ? '' : 'endTime')
    ..aOS(9, _omitFieldNames ? '' : 'mode')
    ..aOS(10, _omitFieldNames ? '' : 'subgroup')
    ..aOS(11, _omitFieldNames ? '' : 'lessonType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleItem copyWith(void Function(ScheduleItem) updates) =>
      super.copyWith((message) => updates(message as ScheduleItem))
          as ScheduleItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScheduleItem create() => ScheduleItem._();
  @$core.override
  ScheduleItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScheduleItem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScheduleItem>(create);
  static ScheduleItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get groupId => $_getIZ(1);
  @$pb.TagNumber(2)
  set groupId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get dayOfWeek => $_getIZ(2);
  @$pb.TagNumber(3)
  set dayOfWeek($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDayOfWeek() => $_has(2);
  @$pb.TagNumber(3)
  void clearDayOfWeek() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get subject => $_getSZ(3);
  @$pb.TagNumber(4)
  set subject($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSubject() => $_has(3);
  @$pb.TagNumber(4)
  void clearSubject() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get teacher => $_getSZ(4);
  @$pb.TagNumber(5)
  set teacher($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTeacher() => $_has(4);
  @$pb.TagNumber(5)
  void clearTeacher() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get room => $_getSZ(5);
  @$pb.TagNumber(6)
  set room($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRoom() => $_has(5);
  @$pb.TagNumber(6)
  void clearRoom() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get startTime => $_getSZ(6);
  @$pb.TagNumber(7)
  set startTime($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStartTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearStartTime() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get endTime => $_getSZ(7);
  @$pb.TagNumber(8)
  set endTime($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasEndTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearEndTime() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get mode => $_getSZ(8);
  @$pb.TagNumber(9)
  set mode($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMode() => $_has(8);
  @$pb.TagNumber(9)
  void clearMode() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get subgroup => $_getSZ(9);
  @$pb.TagNumber(10)
  set subgroup($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasSubgroup() => $_has(9);
  @$pb.TagNumber(10)
  void clearSubgroup() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get lessonType => $_getSZ(10);
  @$pb.TagNumber(11)
  set lessonType($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasLessonType() => $_has(10);
  @$pb.TagNumber(11)
  void clearLessonType() => $_clearField(11);
}

class FacultiesResponse extends $pb.GeneratedMessage {
  factory FacultiesResponse({
    $core.Iterable<Faculty>? faculties,
  }) {
    final result = create();
    if (faculties != null) result.faculties.addAll(faculties);
    return result;
  }

  FacultiesResponse._();

  factory FacultiesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FacultiesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FacultiesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'schedule'),
      createEmptyInstance: create)
    ..pPM<Faculty>(1, _omitFieldNames ? '' : 'faculties',
        subBuilder: Faculty.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FacultiesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FacultiesResponse copyWith(void Function(FacultiesResponse) updates) =>
      super.copyWith((message) => updates(message as FacultiesResponse))
          as FacultiesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FacultiesResponse create() => FacultiesResponse._();
  @$core.override
  FacultiesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FacultiesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FacultiesResponse>(create);
  static FacultiesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Faculty> get faculties => $_getList(0);
}

class GroupsRequest extends $pb.GeneratedMessage {
  factory GroupsRequest({
    $core.int? facultyId,
    $core.int? eduFormId,
  }) {
    final result = create();
    if (facultyId != null) result.facultyId = facultyId;
    if (eduFormId != null) result.eduFormId = eduFormId;
    return result;
  }

  GroupsRequest._();

  factory GroupsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GroupsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GroupsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'schedule'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'facultyId')
    ..aI(2, _omitFieldNames ? '' : 'eduFormId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupsRequest copyWith(void Function(GroupsRequest) updates) =>
      super.copyWith((message) => updates(message as GroupsRequest))
          as GroupsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupsRequest create() => GroupsRequest._();
  @$core.override
  GroupsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GroupsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GroupsRequest>(create);
  static GroupsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get facultyId => $_getIZ(0);
  @$pb.TagNumber(1)
  set facultyId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFacultyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFacultyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get eduFormId => $_getIZ(1);
  @$pb.TagNumber(2)
  set eduFormId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEduFormId() => $_has(1);
  @$pb.TagNumber(2)
  void clearEduFormId() => $_clearField(2);
}

class GroupsResponse extends $pb.GeneratedMessage {
  factory GroupsResponse({
    $core.Iterable<Group>? groups,
  }) {
    final result = create();
    if (groups != null) result.groups.addAll(groups);
    return result;
  }

  GroupsResponse._();

  factory GroupsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GroupsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GroupsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'schedule'),
      createEmptyInstance: create)
    ..pPM<Group>(1, _omitFieldNames ? '' : 'groups', subBuilder: Group.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupsResponse copyWith(void Function(GroupsResponse) updates) =>
      super.copyWith((message) => updates(message as GroupsResponse))
          as GroupsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupsResponse create() => GroupsResponse._();
  @$core.override
  GroupsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GroupsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GroupsResponse>(create);
  static GroupsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Group> get groups => $_getList(0);
}

class ScheduleRequest extends $pb.GeneratedMessage {
  factory ScheduleRequest({
    $core.int? groupId,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    return result;
  }

  ScheduleRequest._();

  factory ScheduleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScheduleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScheduleRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'schedule'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'groupId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleRequest copyWith(void Function(ScheduleRequest) updates) =>
      super.copyWith((message) => updates(message as ScheduleRequest))
          as ScheduleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScheduleRequest create() => ScheduleRequest._();
  @$core.override
  ScheduleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScheduleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScheduleRequest>(create);
  static ScheduleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get groupId => $_getIZ(0);
  @$pb.TagNumber(1)
  set groupId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);
}

class ScheduleResponse extends $pb.GeneratedMessage {
  factory ScheduleResponse({
    $core.Iterable<ScheduleItem>? schedule,
  }) {
    final result = create();
    if (schedule != null) result.schedule.addAll(schedule);
    return result;
  }

  ScheduleResponse._();

  factory ScheduleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScheduleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScheduleResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'schedule'),
      createEmptyInstance: create)
    ..pPM<ScheduleItem>(1, _omitFieldNames ? '' : 'schedule',
        subBuilder: ScheduleItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScheduleResponse copyWith(void Function(ScheduleResponse) updates) =>
      super.copyWith((message) => updates(message as ScheduleResponse))
          as ScheduleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScheduleResponse create() => ScheduleResponse._();
  @$core.override
  ScheduleResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScheduleResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScheduleResponse>(create);
  static ScheduleResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ScheduleItem> get schedule => $_getList(0);
}

class LastUpdatedResponse extends $pb.GeneratedMessage {
  factory LastUpdatedResponse({
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? updates,
  }) {
    final result = create();
    if (updates != null) result.updates.addEntries(updates);
    return result;
  }

  LastUpdatedResponse._();

  factory LastUpdatedResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LastUpdatedResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LastUpdatedResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'schedule'),
      createEmptyInstance: create)
    ..m<$core.String, $core.String>(1, _omitFieldNames ? '' : 'updates',
        entryClassName: 'LastUpdatedResponse.UpdatesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('schedule'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LastUpdatedResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LastUpdatedResponse copyWith(void Function(LastUpdatedResponse) updates) =>
      super.copyWith((message) => updates(message as LastUpdatedResponse))
          as LastUpdatedResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LastUpdatedResponse create() => LastUpdatedResponse._();
  @$core.override
  LastUpdatedResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LastUpdatedResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LastUpdatedResponse>(create);
  static LastUpdatedResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, $core.String> get updates => $_getMap(0);
}

class SGUPathRequest extends $pb.GeneratedMessage {
  factory SGUPathRequest({
    $core.String? faculty,
    $core.String? form,
    $core.String? group,
  }) {
    final result = create();
    if (faculty != null) result.faculty = faculty;
    if (form != null) result.form = form;
    if (group != null) result.group = group;
    return result;
  }

  SGUPathRequest._();

  factory SGUPathRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SGUPathRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SGUPathRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'schedule'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'faculty')
    ..aOS(2, _omitFieldNames ? '' : 'form')
    ..aOS(3, _omitFieldNames ? '' : 'group')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SGUPathRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SGUPathRequest copyWith(void Function(SGUPathRequest) updates) =>
      super.copyWith((message) => updates(message as SGUPathRequest))
          as SGUPathRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SGUPathRequest create() => SGUPathRequest._();
  @$core.override
  SGUPathRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SGUPathRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SGUPathRequest>(create);
  static SGUPathRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get faculty => $_getSZ(0);
  @$pb.TagNumber(1)
  set faculty($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFaculty() => $_has(0);
  @$pb.TagNumber(1)
  void clearFaculty() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get form => $_getSZ(1);
  @$pb.TagNumber(2)
  set form($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasForm() => $_has(1);
  @$pb.TagNumber(2)
  void clearForm() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get group => $_getSZ(2);
  @$pb.TagNumber(3)
  set group($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGroup() => $_has(2);
  @$pb.TagNumber(3)
  void clearGroup() => $_clearField(3);
}

class ScrapeResponse extends $pb.GeneratedMessage {
  factory ScrapeResponse({
    $core.bool? success,
  }) {
    final result = create();
    if (success != null) result.success = success;
    return result;
  }

  ScrapeResponse._();

  factory ScrapeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScrapeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScrapeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'schedule'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScrapeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScrapeResponse copyWith(void Function(ScrapeResponse) updates) =>
      super.copyWith((message) => updates(message as ScrapeResponse))
          as ScrapeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScrapeResponse create() => ScrapeResponse._();
  @$core.override
  ScrapeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScrapeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScrapeResponse>(create);
  static ScrapeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
}

class ScrapeStatusResponse extends $pb.GeneratedMessage {
  factory ScrapeStatusResponse({
    $core.bool? running,
    $core.String? lastTrigger,
    $core.String? lastStartedAt,
    $core.String? lastFinishedAt,
    $fixnum.Int64? lastDurationMs,
    $core.String? lastError,
  }) {
    final result = create();
    if (running != null) result.running = running;
    if (lastTrigger != null) result.lastTrigger = lastTrigger;
    if (lastStartedAt != null) result.lastStartedAt = lastStartedAt;
    if (lastFinishedAt != null) result.lastFinishedAt = lastFinishedAt;
    if (lastDurationMs != null) result.lastDurationMs = lastDurationMs;
    if (lastError != null) result.lastError = lastError;
    return result;
  }

  ScrapeStatusResponse._();

  factory ScrapeStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScrapeStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScrapeStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'schedule'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'running')
    ..aOS(2, _omitFieldNames ? '' : 'lastTrigger')
    ..aOS(3, _omitFieldNames ? '' : 'lastStartedAt')
    ..aOS(4, _omitFieldNames ? '' : 'lastFinishedAt')
    ..aInt64(5, _omitFieldNames ? '' : 'lastDurationMs')
    ..aOS(6, _omitFieldNames ? '' : 'lastError')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScrapeStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScrapeStatusResponse copyWith(void Function(ScrapeStatusResponse) updates) =>
      super.copyWith((message) => updates(message as ScrapeStatusResponse))
          as ScrapeStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScrapeStatusResponse create() => ScrapeStatusResponse._();
  @$core.override
  ScrapeStatusResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScrapeStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScrapeStatusResponse>(create);
  static ScrapeStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get running => $_getBF(0);
  @$pb.TagNumber(1)
  set running($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRunning() => $_has(0);
  @$pb.TagNumber(1)
  void clearRunning() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get lastTrigger => $_getSZ(1);
  @$pb.TagNumber(2)
  set lastTrigger($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLastTrigger() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastTrigger() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get lastStartedAt => $_getSZ(2);
  @$pb.TagNumber(3)
  set lastStartedAt($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLastStartedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastStartedAt() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get lastFinishedAt => $_getSZ(3);
  @$pb.TagNumber(4)
  set lastFinishedAt($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLastFinishedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearLastFinishedAt() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get lastDurationMs => $_getI64(4);
  @$pb.TagNumber(5)
  set lastDurationMs($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLastDurationMs() => $_has(4);
  @$pb.TagNumber(5)
  void clearLastDurationMs() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get lastError => $_getSZ(5);
  @$pb.TagNumber(6)
  set lastError($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLastError() => $_has(5);
  @$pb.TagNumber(6)
  void clearLastError() => $_clearField(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
