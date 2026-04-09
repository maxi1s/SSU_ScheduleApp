// This is a generated file - do not edit.
//
// Generated from schedule.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'schedule.pb.dart' as $0;

export 'schedule.pb.dart';

@$pb.GrpcServiceName('schedule.ScheduleService')
class ScheduleServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ScheduleServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.FacultiesResponse> getFaculties(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getFaculties, request, options: options);
  }

  $grpc.ResponseFuture<$0.GroupsResponse> getGroups(
    $0.GroupsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getGroups, request, options: options);
  }

  $grpc.ResponseFuture<$0.ScheduleResponse> getSchedule(
    $0.ScheduleRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getSchedule, request, options: options);
  }

  $grpc.ResponseFuture<$0.LastUpdatedResponse> getLastUpdated(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getLastUpdated, request, options: options);
  }

  $grpc.ResponseFuture<$0.ScheduleResponse> getScheduleByPath(
    $0.SGUPathRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getScheduleByPath, request, options: options);
  }

  $grpc.ResponseFuture<$0.ScrapeResponse> runScrape(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$runScrape, request, options: options);
  }

  $grpc.ResponseFuture<$0.ScrapeStatusResponse> getScrapeStatus(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getScrapeStatus, request, options: options);
  }

  // method descriptors

  static final _$getFaculties =
      $grpc.ClientMethod<$0.Empty, $0.FacultiesResponse>(
          '/schedule.ScheduleService/GetFaculties',
          ($0.Empty value) => value.writeToBuffer(),
          $0.FacultiesResponse.fromBuffer);
  static final _$getGroups =
      $grpc.ClientMethod<$0.GroupsRequest, $0.GroupsResponse>(
          '/schedule.ScheduleService/GetGroups',
          ($0.GroupsRequest value) => value.writeToBuffer(),
          $0.GroupsResponse.fromBuffer);
  static final _$getSchedule =
      $grpc.ClientMethod<$0.ScheduleRequest, $0.ScheduleResponse>(
          '/schedule.ScheduleService/GetSchedule',
          ($0.ScheduleRequest value) => value.writeToBuffer(),
          $0.ScheduleResponse.fromBuffer);
  static final _$getLastUpdated =
      $grpc.ClientMethod<$0.Empty, $0.LastUpdatedResponse>(
          '/schedule.ScheduleService/GetLastUpdated',
          ($0.Empty value) => value.writeToBuffer(),
          $0.LastUpdatedResponse.fromBuffer);
  static final _$getScheduleByPath =
      $grpc.ClientMethod<$0.SGUPathRequest, $0.ScheduleResponse>(
          '/schedule.ScheduleService/GetScheduleByPath',
          ($0.SGUPathRequest value) => value.writeToBuffer(),
          $0.ScheduleResponse.fromBuffer);
  static final _$runScrape = $grpc.ClientMethod<$0.Empty, $0.ScrapeResponse>(
      '/schedule.ScheduleService/RunScrape',
      ($0.Empty value) => value.writeToBuffer(),
      $0.ScrapeResponse.fromBuffer);
  static final _$getScrapeStatus =
      $grpc.ClientMethod<$0.Empty, $0.ScrapeStatusResponse>(
          '/schedule.ScheduleService/GetScrapeStatus',
          ($0.Empty value) => value.writeToBuffer(),
          $0.ScrapeStatusResponse.fromBuffer);
}

@$pb.GrpcServiceName('schedule.ScheduleService')
abstract class ScheduleServiceBase extends $grpc.Service {
  $core.String get $name => 'schedule.ScheduleService';

  ScheduleServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.FacultiesResponse>(
        'GetFaculties',
        getFaculties_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.FacultiesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GroupsRequest, $0.GroupsResponse>(
        'GetGroups',
        getGroups_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GroupsRequest.fromBuffer(value),
        ($0.GroupsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ScheduleRequest, $0.ScheduleResponse>(
        'GetSchedule',
        getSchedule_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ScheduleRequest.fromBuffer(value),
        ($0.ScheduleResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.LastUpdatedResponse>(
        'GetLastUpdated',
        getLastUpdated_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.LastUpdatedResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SGUPathRequest, $0.ScheduleResponse>(
        'GetScheduleByPath',
        getScheduleByPath_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SGUPathRequest.fromBuffer(value),
        ($0.ScheduleResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ScrapeResponse>(
        'RunScrape',
        runScrape_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ScrapeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ScrapeStatusResponse>(
        'GetScrapeStatus',
        getScrapeStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ScrapeStatusResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.FacultiesResponse> getFaculties_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getFaculties($call, await $request);
  }

  $async.Future<$0.FacultiesResponse> getFaculties(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.GroupsResponse> getGroups_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.GroupsRequest> $request) async {
    return getGroups($call, await $request);
  }

  $async.Future<$0.GroupsResponse> getGroups(
      $grpc.ServiceCall call, $0.GroupsRequest request);

  $async.Future<$0.ScheduleResponse> getSchedule_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ScheduleRequest> $request) async {
    return getSchedule($call, await $request);
  }

  $async.Future<$0.ScheduleResponse> getSchedule(
      $grpc.ServiceCall call, $0.ScheduleRequest request);

  $async.Future<$0.LastUpdatedResponse> getLastUpdated_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getLastUpdated($call, await $request);
  }

  $async.Future<$0.LastUpdatedResponse> getLastUpdated(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.ScheduleResponse> getScheduleByPath_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SGUPathRequest> $request) async {
    return getScheduleByPath($call, await $request);
  }

  $async.Future<$0.ScheduleResponse> getScheduleByPath(
      $grpc.ServiceCall call, $0.SGUPathRequest request);

  $async.Future<$0.ScrapeResponse> runScrape_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return runScrape($call, await $request);
  }

  $async.Future<$0.ScrapeResponse> runScrape(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.ScrapeStatusResponse> getScrapeStatus_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getScrapeStatus($call, await $request);
  }

  $async.Future<$0.ScrapeStatusResponse> getScrapeStatus(
      $grpc.ServiceCall call, $0.Empty request);
}
