// Copyright (c) 2017, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:jaguar/jaguar.dart';
import 'package:jaguar_serializer/serializer.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

/// Interceptor to encode and decode JSON
class Codec<BodyType, RespType> extends Interceptor<BodyType, String, RespType> {
  final Serializer<BodyType> bodySerializer;

  final Serializer<RespType> respSerializer;

  final Encoding bodyEncoding;

  const Codec(this.bodySerializer, this.respSerializer,
      {this.bodyEncoding: UTF8});

  Future<BodyType> pre(Context ctx) async {
    String data = await ctx.req.bodyAsText(bodyEncoding);
    if (data.isNotEmpty) {
      return bodySerializer.fromMap(JSON.decode(data));
    }

    return null;
  }

  Response<String> post(Context ctx, Response<RespType> incoming) {
    Response<String> resp = new Response<String>.cloneExceptValue(incoming);
    resp.value =
        JSON.encode(respSerializer.toMap(incoming.value, withType: true));
    resp.headers.mimeType = ContentType.JSON.mimeType;
    return resp;
  }
}

/// Interceptor to encode and decode JSlON
class CodecRepo extends Interceptor {
  final Encoding bodyEncoding;

  final SerializerRepo repo;

  const CodecRepo(this.repo, {this.bodyEncoding: UTF8});

  Future<dynamic> pre(Context ctx) async {
    final data = await ctx.req.bodyAsText(bodyEncoding);
    if (data.isNotEmpty) {
      return bodySerializer.fromMap(JSON.decode(data));
    }

    return null;
  }

  Response<String> post(Context ctx, Response incoming) {
    Response<String> resp = new Response<String>.cloneExceptValue(incoming);
    resp.value =
        JSON.encode(respSerializer.toMap(incoming.value, withType: true));
    resp.headers.mimeType = ContentType.JSON.mimeType;
    return resp;
  }
}

class Encode<ModelType> extends Interceptor<Null, String, ModelType> {
  final Serializer<ModelType> serializer;

  final bool withType;

  final String typeKey;

  const Encode(this.serializer, {this.withType: false, this.typeKey});

  Null pre(_) => null;

  Response<String> post(Context ctx, Response<ModelType> incoming) {
    Response<String> resp = new Response<String>.cloneExceptValue(incoming);
    resp.value = JSON.encode(
        serializer.toMap(incoming.value, withType: withType, typeKey: typeKey));
    resp.headers.mimeType = ContentType.JSON.mimeType;
    return resp;
  }
}

class Decode<ModelType> extends Interceptor {
  final Serializer<ModelType> serializer;

  final Encoding encoding;

  Decode(this.serializer, {this.encoding: UTF8});

  Future<dynamic> pre(Context ctx) async {
    String data = await ctx.req.bodyAsText(encoding);
    if (data.isNotEmpty) {
      return serializer.fromMap(JSON.decode(data));
    }

    return null;
  }
}

class EncodeRepo extends Interceptor {
  final JsonRepo repo;

  final bool withType;

  final String typeKey;

  EncodeRepo(this.repo, {this.withType: false, this.typeKey});

  Null pre(_) => null;

  Response<String> post(Context ctx, Response<dynamic> incoming) {
    Response<String> resp = new Response<String>.cloneExceptValue(incoming);
    resp.value =
        repo.serialize(incoming.value, withType: withType, typeKey: typeKey);
    resp.headers.mimeType = ContentType.JSON.mimeType;
    return resp;
  }
}

class DecodeRepo extends Interceptor {
  final JsonRepo repo;

  final Encoding encoding;

  final String typeKey;

  DecodeRepo(this.repo, {this.encoding: UTF8, this.typeKey});

  Future<dynamic> pre(Context ctx) async {
    String data = await ctx.req.bodyAsText(encoding);
    if (data.isNotEmpty) {
      return repo.deserialize(data, typeKey: typeKey);
    }

    return null;
  }
}