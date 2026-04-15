// This is a generated file - do not edit.
//
// Generated from schedule.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use emptyDescriptor instead')
const Empty$json = {
  '1': 'Empty',
};

/// Descriptor for `Empty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyDescriptor =
    $convert.base64Decode('CgVFbXB0eQ==');

@$core.Deprecated('Use facultyDescriptor instead')
const Faculty$json = {
  '1': 'Faculty',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `Faculty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List facultyDescriptor = $convert.base64Decode(
    'CgdGYWN1bHR5Eg4KAmlkGAEgASgFUgJpZBISCgRuYW1lGAIgASgJUgRuYW1l');

@$core.Deprecated('Use groupDescriptor instead')
const Group$json = {
  '1': 'Group',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'faculty_id', '3': 3, '4': 1, '5': 5, '10': 'facultyId'},
    {'1': 'edu_form_id', '3': 4, '4': 1, '5': 5, '10': 'eduFormId'},
  ],
};

/// Descriptor for `Group`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupDescriptor = $convert.base64Decode(
    'CgVHcm91cBIOCgJpZBgBIAEoBVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIdCgpmYWN1bHR5X2'
    'lkGAMgASgFUglmYWN1bHR5SWQSHgoLZWR1X2Zvcm1faWQYBCABKAVSCWVkdUZvcm1JZA==');

@$core.Deprecated('Use scheduleItemDescriptor instead')
const ScheduleItem$json = {
  '1': 'ScheduleItem',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 5, '10': 'groupId'},
    {'1': 'day_of_week', '3': 3, '4': 1, '5': 5, '10': 'dayOfWeek'},
    {'1': 'subject', '3': 4, '4': 1, '5': 9, '10': 'subject'},
    {'1': 'teacher', '3': 5, '4': 1, '5': 9, '10': 'teacher'},
    {'1': 'room', '3': 6, '4': 1, '5': 9, '10': 'room'},
    {'1': 'start_time', '3': 7, '4': 1, '5': 9, '10': 'startTime'},
    {'1': 'end_time', '3': 8, '4': 1, '5': 9, '10': 'endTime'},
    {'1': 'mode', '3': 9, '4': 1, '5': 9, '10': 'mode'},
    {'1': 'subgroup', '3': 10, '4': 1, '5': 9, '10': 'subgroup'},
    {'1': 'lesson_type', '3': 11, '4': 1, '5': 9, '10': 'lessonType'},
  ],
};

/// Descriptor for `ScheduleItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scheduleItemDescriptor = $convert.base64Decode(
    'CgxTY2hlZHVsZUl0ZW0SDgoCaWQYASABKAVSAmlkEhkKCGdyb3VwX2lkGAIgASgFUgdncm91cE'
    'lkEh4KC2RheV9vZl93ZWVrGAMgASgFUglkYXlPZldlZWsSGAoHc3ViamVjdBgEIAEoCVIHc3Vi'
    'amVjdBIYCgd0ZWFjaGVyGAUgASgJUgd0ZWFjaGVyEhIKBHJvb20YBiABKAlSBHJvb20SHQoKc3'
    'RhcnRfdGltZRgHIAEoCVIJc3RhcnRUaW1lEhkKCGVuZF90aW1lGAggASgJUgdlbmRUaW1lEhIK'
    'BG1vZGUYCSABKAlSBG1vZGUSGgoIc3ViZ3JvdXAYCiABKAVSCHN1Ymdyb3Vw');

@$core.Deprecated('Use facultiesResponseDescriptor instead')
const FacultiesResponse$json = {
  '1': 'FacultiesResponse',
  '2': [
    {
      '1': 'faculties',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.schedule.Faculty',
      '10': 'faculties'
    },
  ],
};

/// Descriptor for `FacultiesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List facultiesResponseDescriptor = $convert.base64Decode(
    'ChFGYWN1bHRpZXNSZXNwb25zZRIvCglmYWN1bHRpZXMYASADKAsyES5zY2hlZHVsZS5GYWN1bH'
    'R5UglmYWN1bHRpZXM=');

@$core.Deprecated('Use groupsRequestDescriptor instead')
const GroupsRequest$json = {
  '1': 'GroupsRequest',
  '2': [
    {'1': 'faculty_id', '3': 1, '4': 1, '5': 5, '10': 'facultyId'},
    {'1': 'edu_form_id', '3': 2, '4': 1, '5': 5, '10': 'eduFormId'},
  ],
};

/// Descriptor for `GroupsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupsRequestDescriptor = $convert.base64Decode(
    'Cg1Hcm91cHNSZXF1ZXN0Eh0KCmZhY3VsdHlfaWQYASABKAVSCWZhY3VsdHlJZBIeCgtlZHVfZm'
    '9ybV9pZBgCIAEoBVIJZWR1Rm9ybUlk');

@$core.Deprecated('Use groupsResponseDescriptor instead')
const GroupsResponse$json = {
  '1': 'GroupsResponse',
  '2': [
    {
      '1': 'groups',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.schedule.Group',
      '10': 'groups'
    },
  ],
};

/// Descriptor for `GroupsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupsResponseDescriptor = $convert.base64Decode(
    'Cg5Hcm91cHNSZXNwb25zZRInCgZncm91cHMYASADKAsyDy5zY2hlZHVsZS5Hcm91cFIGZ3JvdX'
    'Bz');

@$core.Deprecated('Use scheduleRequestDescriptor instead')
const ScheduleRequest$json = {
  '1': 'ScheduleRequest',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 5, '10': 'groupId'},
  ],
};

/// Descriptor for `ScheduleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scheduleRequestDescriptor = $convert.base64Decode(
    'Cg9TY2hlZHVsZVJlcXVlc3QSGQoIZ3JvdXBfaWQYASABKAVSB2dyb3VwSWQ=');

@$core.Deprecated('Use scheduleResponseDescriptor instead')
const ScheduleResponse$json = {
  '1': 'ScheduleResponse',
  '2': [
    {
      '1': 'schedule',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.schedule.ScheduleItem',
      '10': 'schedule'
    },
  ],
};

/// Descriptor for `ScheduleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scheduleResponseDescriptor = $convert.base64Decode(
    'ChBTY2hlZHVsZVJlc3BvbnNlEjIKCHNjaGVkdWxlGAEgAygLMhYuc2NoZWR1bGUuU2NoZWR1bG'
    'VJdGVtUghzY2hlZHVsZQ==');

@$core.Deprecated('Use lastUpdatedResponseDescriptor instead')
const LastUpdatedResponse$json = {
  '1': 'LastUpdatedResponse',
  '2': [
    {
      '1': 'updates',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.schedule.LastUpdatedResponse.UpdatesEntry',
      '10': 'updates'
    },
  ],
  '3': [LastUpdatedResponse_UpdatesEntry$json],
};

@$core.Deprecated('Use lastUpdatedResponseDescriptor instead')
const LastUpdatedResponse_UpdatesEntry$json = {
  '1': 'UpdatesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `LastUpdatedResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List lastUpdatedResponseDescriptor = $convert.base64Decode(
    'ChNMYXN0VXBkYXRlZFJlc3BvbnNlEkQKB3VwZGF0ZXMYASADKAsyKi5zY2hlZHVsZS5MYXN0VX'
    'BkYXRlZFJlc3BvbnNlLlVwZGF0ZXNFbnRyeVIHdXBkYXRlcxo6CgxVcGRhdGVzRW50cnkSEAoD'
    'a2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use sGUPathRequestDescriptor instead')
const SGUPathRequest$json = {
  '1': 'SGUPathRequest',
  '2': [
    {'1': 'faculty', '3': 1, '4': 1, '5': 9, '10': 'faculty'},
    {'1': 'form', '3': 2, '4': 1, '5': 9, '10': 'form'},
    {'1': 'group', '3': 3, '4': 1, '5': 9, '10': 'group'},
  ],
};

/// Descriptor for `SGUPathRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sGUPathRequestDescriptor = $convert.base64Decode(
    'Cg5TR1VQYXRoUmVxdWVzdBIYCgdmYWN1bHR5GAEgASgJUgdmYWN1bHR5EhIKBGZvcm0YAiABKA'
    'lSBGZvcm0SFAoFZ3JvdXAYAyABKAlSBWdyb3Vw');

@$core.Deprecated('Use scrapeResponseDescriptor instead')
const ScrapeResponse$json = {
  '1': 'ScrapeResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `ScrapeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scrapeResponseDescriptor = $convert
    .base64Decode('Cg5TY3JhcGVSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNz');

@$core.Deprecated('Use scrapeStatusResponseDescriptor instead')
const ScrapeStatusResponse$json = {
  '1': 'ScrapeStatusResponse',
  '2': [
    {'1': 'running', '3': 1, '4': 1, '5': 8, '10': 'running'},
    {'1': 'last_trigger', '3': 2, '4': 1, '5': 9, '10': 'lastTrigger'},
    {'1': 'last_started_at', '3': 3, '4': 1, '5': 9, '10': 'lastStartedAt'},
    {'1': 'last_finished_at', '3': 4, '4': 1, '5': 9, '10': 'lastFinishedAt'},
    {'1': 'last_duration_ms', '3': 5, '4': 1, '5': 3, '10': 'lastDurationMs'},
    {'1': 'last_error', '3': 6, '4': 1, '5': 9, '10': 'lastError'},
  ],
};

/// Descriptor for `ScrapeStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scrapeStatusResponseDescriptor = $convert.base64Decode(
    'ChRTY3JhcGVTdGF0dXNSZXNwb25zZRIYCgdydW5uaW5nGAEgASgIUgdydW5uaW5nEiEKDGxhc3'
    'RfdHJpZ2dlchgCIAEoCVILbGFzdFRyaWdnZXISJgoPbGFzdF9zdGFydGVkX2F0GAMgASgJUg1s'
    'YXN0U3RhcnRlZEF0EigKEGxhc3RfZmluaXNoZWRfYXQYBCABKAlSDmxhc3RGaW5pc2hlZEF0Ei'
    'gKEGxhc3RfZHVyYXRpb25fbXMYBSABKANSDmxhc3REdXJhdGlvbk1zEh0KCmxhc3RfZXJyb3IY'
    'BiABKAlSCWxhc3RFcnJvcg==');
