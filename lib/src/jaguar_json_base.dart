// Copyright (c) 2017, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:jaguar/jaguar.dart';
import 'package:jaguar_serializer/serializer.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

class WrapEncodeJson<ModelType> extends RouteWrapper<EncodeJson> {
  final String id;

  final Serializer<ModelType> serializer;

  final bool withType;

  final String typeKey;

  const WrapEncodeJson(this.serializer,
      {this.id, this.withType: false, this.typeKey});

  EncodeJson<ModelType> createInterceptor() =>
      new EncodeJson<ModelType>(serializer,
          withType: withType, typeKey: this.typeKey);
}

class EncodeJson<ModelType> extends Interceptor {
  final Serializer<ModelType> serializer;

  final bool withType;

  final String typeKey;

  EncodeJson(this.serializer, {this.withType: false, this.typeKey});

  @InputRouteResponse()
  Response<String> post(Response<ModelType> incoming) {
    Response<String> resp = new Response<String>.cloneExceptValue(incoming);
    resp.value = JSON.encode(
        serializer.toMap(incoming.value, withType: withType, typeKey: typeKey));
    resp.headers.mimeType = ContentType.JSON.mimeType;
    return resp;
  }
}

class WrapDecodeJson<ModelType> extends RouteWrapper<DecodeJson> {
  final String id;

  final Serializer<ModelType> serializer;

  final Encoding encoding;

  const WrapDecodeJson(this.serializer, {this.id, this.encoding: UTF8});

  DecodeJson<ModelType> createInterceptor() =>
      new DecodeJson<ModelType>(serializer, encoding: encoding);
}

class DecodeJson<ModelType> extends Interceptor {
  final Serializer<ModelType> serializer;

  final Encoding encoding;

  DecodeJson(this.serializer, {this.encoding: UTF8});

  Future<dynamic> pre(Request req) async {
    String data = await req.bodyAsText(encoding);
    if (data.isNotEmpty) {
      return serializer.fromMap(JSON.decode(data));
    }

    return null;
  }
}

class WrapEncodeJsonRepo extends RouteWrapper<EncodeJsonRepo> {
  final String id;

  final JsonRepo repo;

  final bool withType;

  final String typeKey;

  const WrapEncodeJsonRepo(this.repo,
      {this.id, this.withType: false, this.typeKey});

  EncodeJsonRepo createInterceptor() =>
      new EncodeJsonRepo(repo, withType: withType, typeKey: this.typeKey);
}

class EncodeJsonRepo extends Interceptor {
  final JsonRepo repo;

  final bool withType;

  final String typeKey;

  EncodeJsonRepo(this.repo, {this.withType: false, this.typeKey});

  @InputRouteResponse()
  Response<String> post(Response<dynamic> incoming) {
    Response<String> resp = new Response<String>.cloneExceptValue(incoming);
    resp.value =
        repo.serialize(incoming.value, withType: withType, typeKey: typeKey);
    resp.headers.mimeType = ContentType.JSON.mimeType;
    return resp;
  }
}

class WrapDecodeJsonRepo extends RouteWrapper<DecodeJsonRepo> {
  final String id;

  final JsonRepo repo;

  final Encoding encoding;

  final String typeKey;

  const WrapDecodeJsonRepo(this.repo,
      {this.id, this.encoding: UTF8, this.typeKey});

  DecodeJsonRepo createInterceptor() =>
      new DecodeJsonRepo(repo, encoding: encoding, typeKey: this.typeKey);
}

class DecodeJsonRepo extends Interceptor {
  final JsonRepo repo;

  final Encoding encoding;

  final String typeKey;

  DecodeJsonRepo(this.repo,
      {this.encoding: UTF8, this.typeKey});

  Future<dynamic> pre(Request req) async {
    String data = await req.bodyAsText(encoding);
    if (data.isNotEmpty) {
      return repo.deserialize(data, typeKey: typeKey);
    }

    return null;
  }
}
