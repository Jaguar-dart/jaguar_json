// Copyright (c) 2017, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// Provides [Interceptor]s, utility functions and mixins to make JSON encoding
/// and decoding from/to HTTP requests/responses easier.
///
/// [Interceptors]:
/// 1. [Codec]
/// 2. [Encode]
/// 3. [Decode]
/// 4. [CodecRepo]
/// 5. [EncodeRepo]
/// 6. [DecodeRepo]
///
/// Mixins:
/// 1. [JsonRoutes]
///
/// Utility functions:
/// 1. [deserialize]
/// 2. [serialize]
library jaguar.json;

import 'package:jaguar/jaguar.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

part 'interceptor_repo.dart';
part 'interceptor_serializer.dart';

/// Uses [serializer] to deserialize JSON HTTP body from [ctx]. Returns the
/// deserialized object.
///
///     @Api(path: '/api/book')
///     class BookRoutes {
///       @Post()
///       Future<Response<String>> post(Context ctx) async => json.serialize(
///         bookSerializer, await json.deserialize(bookSerializer, ctx));
///     }
Future<dynamic> deserialize<T>(Serializer<T> serializer, Context ctx) async {
  final body = await ctx.req.bodyAsJson();
  return serializer.deserialize(body);
}

/// Uses [serializer] to serialize [object] to JSON. Returns [Response] object
/// with serialized JSON body.
///
///     @Api(path: '/api/book')
///     class BookRoutes {
///       @Get()
///       Response<String> get(Context ctx) =>
///         json.serialize(bookSerializer, new Book.fromNum(5));
///     }
Response<String> serialize<T>(Serializer<T> serializer, object,
        {int statusCode: 200, Map<String, dynamic> headers: const {}}) =>
    Response.json(serializer.serialize(object, withType: true),
        statusCode: statusCode, headers: headers);

/// A mixin for [RequestHandler]s to make encoding and decoding to JSON easy.
///
/// Use [fromJson] to obtain deserialized Dart object from JSON HTTP body with a
/// single call.
///
/// Use [toJSON] to compose a [Response] object with serialized JSON body.
///
/// It uses [repo] to deserialize and serialize JSON.
///
///     @Api(path: '/api/book')
///     class BookRoutes extends Object with JsonRoutes {
///       JsonRepo get repo => models.repo;
///
///       @Get()
///       Response<String> get(Context ctx) => toJson(new Book.fromNum(5));
///
///       @Post()
///       Future<Response<String>> post(Context ctx) async =>
///         toJson(await fromJson(ctx));
///     }
abstract class JsonRoutes {
  /// Repository used to decode and encode JSON
  JsonRepo get repo;

  /// Uses [repo] to deserialize JSON HTTP body from [ctx]. Returns the
  /// deserialized object.
  ///
  ///     @Api(path: '/api/book')
  ///     class BookRoutes extends Object with JsonRoutes {
  ///       JsonRepo get repo => models.repo;
  ///
  ///       @Post()
  ///       Future<Response<String>> post(Context ctx) async =>
  ///         toJson(await fromJson(ctx));
  ///     }
  Future<dynamic> fromJson(Context ctx, {Type type}) async {
    final body = await ctx.req.bodyAsText(UTF8);
    return repo.deserialize(body, type: type);
  }

  /// Uses [repo] to serialize [object] to JSON. Returns [Response] object with
  /// serialized JSON body.
  ///
  ///     @Api(path: '/api/book')
  ///     class BookRoutes extends Object with JsonRoutes {
  ///       JsonRepo get repo => models.repo;
  ///
  ///       @Get()
  ///       Response<String> get(Context ctx) => toJson(new Book.fromNum(5));
  ///     }
  Response<String> toJson<T>(object,
      {int statusCode: 200,
      Map<String, dynamic> headers: const {},
      bool withType: true}) {
    final resp = new Response(repo.serialize(object, withType: withType),
        statusCode: statusCode, headers: headers);
    resp.headers.mimeType = resp.headers.mimeType = ContentType.JSON.mimeType;
    resp.headers.charset = 'utf-8';
    return resp;
  }
}
