// Copyright (c) 2017, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:jaguar/jaguar.dart';
import 'package:jaguar_serializer/serializer.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

class EncodeJson<ModelType> extends Interceptor<Null, String, ModelType> {
  final Serializer<ModelType> serializer;

  final bool withType;

  final String typeKey;

  const EncodeJson(this.serializer, {this.withType: false, this.typeKey});

  Null pre(_) => null;

  Response<String> post(Context ctx, Response<ModelType> incoming) {
    Response<String> resp = new Response<String>.cloneExceptValue(incoming);
    resp.value = JSON.encode(
        serializer.toMap(incoming.value, withType: withType, typeKey: typeKey));
    resp.headers.mimeType = ContentType.JSON.mimeType;
    return resp;
  }
}

class DecodeJson<ModelType> extends Interceptor {
  final Serializer<ModelType> serializer;

  final Encoding encoding;

  DecodeJson(this.serializer, {this.encoding: UTF8});

  Future<dynamic> pre(Context ctx) async {
    String data = await ctx.req.bodyAsText(encoding);
    if (data.isNotEmpty) {
      return serializer.fromMap(JSON.decode(data));
    }

    return null;
  }
}

class EncodeJsonRepo extends Interceptor {
  final JsonRepo repo;

  final bool withType;

  final String typeKey;

  EncodeJsonRepo(this.repo, {this.withType: false, this.typeKey});

  Null pre(_) => null;

  Response<String> post(Context ctx, Response<dynamic> incoming) {
    Response<String> resp = new Response<String>.cloneExceptValue(incoming);
    resp.value =
        repo.serialize(incoming.value, withType: withType, typeKey: typeKey);
    resp.headers.mimeType = ContentType.JSON.mimeType;
    return resp;
  }
}

class DecodeJsonRepo extends Interceptor {
  final JsonRepo repo;

  final Encoding encoding;

  final String typeKey;

  DecodeJsonRepo(this.repo,
      {this.encoding: UTF8, this.typeKey});

  Future<dynamic> pre(Context ctx) async {
    String data = await ctx.req.bodyAsText(encoding);
    if (data.isNotEmpty) {
      return repo.deserialize(data, typeKey: typeKey);
    }

    return null;
  }
}
