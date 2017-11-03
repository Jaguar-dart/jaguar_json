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
library jaguar_json;

export 'src/jaguar_json.dart';
