part of jaguar.json;

/// Interceptor to encode and decode JSON.
///
/// Uses [bodySerializer] to deserialize Dart objects from JSON.
/// Uses [respSerializer] to serialize Dart objects to JSON.
///
///     @Api(path: '/api/book')
///     class BookRoutes {
///     	json.Codec codec(_) => new json.Codec(bookSerializer, bookSerializer);
///
///     	@Get()
///     	@WrapOne(#codec)
///     	Book get(Context ctx) => new Book.fromNum(5);
///
///     	@Post()
///     	@WrapOne(#codec)
///     	Book post(Context ctx) => ctx.getInterceptorResult<Book>(json.Codec);
///     }
class Codec<BodyType, RespType>
    extends FullInterceptor<BodyType, String, RespType> {
  /// Serializer used to deserialize Dart object from JSON
  final Serializer<BodyType> bodySerializer;

  /// Serializer used to serialize Dart object to JSON
  final Serializer<RespType> respSerializer;

  /// Encoding
  final Encoding bodyEncoding;

  Codec(this.bodySerializer, this.respSerializer, {this.bodyEncoding: UTF8});

  BodyType output;

  Future before(Context ctx) async {
    String data = await ctx.req.bodyAsText(bodyEncoding);
    if (data.isNotEmpty) {
      output = bodySerializer.fromMap(JSON.decode(data));
      ctx.addInterceptor(Codec, id, this);
      return;
    }

    return;
  }

  Response<String> after(Context ctx, Response<RespType> incoming) {
    Response<String> resp = new Response<String>.cloneExceptValue(incoming);
    resp.value =
        JSON.encode(respSerializer.toMap(incoming.value, withType: true));
    resp.headers.mimeType = ContentType.JSON.mimeType;
    return resp;
  }
}

/// Interceptor to encode Dart object of type [ModelType] to JSON [Response]. Uses
/// [serializer] to serialize Dart objects.
///
///     @Api(path: '/api/book')
///     class BookRoutes {
///     	json.Decode decoder(_) => new json.Decode(bookSerializer);
///
///     	json.Encode<Book> encoder(_) => new json.Encode<Book>(bookSerializer);
//
///     	@Post()
///     	@Wrap(const [#decoder, #encoder])
///     	Book one(Context ctx) {
///     		final Book book = ctx.getInterceptorResult(json.Decode);
///     		return book;
///     	}
///
///     	@Post(path: '/many')
///     	@Wrap(const [#decoder, #encoder])
///     	List<Book> list(Context ctx) => ctx.getInterceptorResult(json.Decode);
///     }
class Encode<ModelType> extends FullInterceptor<Null, String, ModelType> {
  /// Serializer used to serialize Dart object to JSON
  final Serializer<ModelType> serializer;

  Encode(this.serializer);

  Null get output => null;

  void before(_) => null;

  Response<String> after(Context ctx, Response<ModelType> incoming) {
    Response<String> resp = new Response<String>.cloneExceptValue(incoming);
    resp.value =
        JSON.encode(serializer.serialize(incoming.value, withType: true));
    resp.headers.mimeType = ContentType.JSON.mimeType;
    return resp;
  }
}

/// Interceptor to decode Dart object of type [ModelType] from JSON HTTP body. Uses
/// [serializer] to deserialize Dart objects.
///
///     @Api(path: '/api/book')
///     class BookRoutes {
///     	json.Decode decoder(_) => new json.Decode(bookSerializer);
///
///     	json.Encode<Book> encoder(_) => new json.Encode<Book>(bookSerializer);
//
///     	@Post()
///     	@Wrap(const [#decoder, #encoder])
///     	Book one(Context ctx) {
///     		final Book book = ctx.getInterceptorResult(json.Decode);
///     		return book;
///     	}
///
///     	@Post(path: '/many')
///     	@Wrap(const [#decoder, #encoder])
///     	List<Book> list(Context ctx) => ctx.getInterceptorResult(json.Decode);
///     }
class Decode<ModelType> extends Interceptor {
  /// Serializer used to deserialize Dart object from JSON
  final Serializer<ModelType> serializer;

  final Encoding encoding;

  Decode(this.serializer, {this.encoding: UTF8});

  ModelType output;

  Future before(Context ctx) async {
    String data = await ctx.req.bodyAsText(encoding);
    if (data.isNotEmpty) {
      output = serializer.deserialize(JSON.decode(data));
      ctx.addInterceptor(Decode, id, this);
      return;
    }

    return;
  }
}
