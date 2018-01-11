part of jaguar.json;

/// Interceptor to encode and decode JSON
///
/// Uses [repo] to serialize and deserialize Dart objects to/from JSON.
///
///     @Api(path: '/api/book')
///     class BookRoutes {
///     	json.CodecRepo codec(_) => new json.CodecRepo(repo);
///
///     	@Get()
///     	@WrapOne(#codec)
///     	Book get(Context ctx) => new Book.fromNum(5);
///
///     	@Post()
///     	@WrapOne(#codec)
///     	Book post(Context ctx) {
///     		final book = ctx.getInterceptorResult<Book>(json.CodecRepo);
///     		return book;
///     	}
///     }
class CodecRepo extends Interceptor {
  /// Encoding
  final Encoding bodyEncoding;

  /// Repository used to decode and encode JSON
  final SerializerRepo repo;

  const CodecRepo(this.repo, {this.bodyEncoding: UTF8});

  Future<dynamic> pre(Context ctx) async {
    final data = await ctx.req.bodyAsText(bodyEncoding);
    if (data.isNotEmpty) return repo.deserialize(data);
    return null;
  }

  Response<String> post(Context ctx, Response incoming) {
    Response<String> resp = new Response<String>.cloneExceptValue(incoming);
    resp.value = repo.serialize(incoming.value, withType: true);
    resp.headers.mimeType = ContentType.JSON.mimeType;
    return resp;
  }
}

/// Interceptor to encode Dart object of type [ModelType] to JSON [Response].
///
/// Uses [repo] to serialize Dart objects.
///
///     @Api(path: '/api/book')
///     class BookRoutes {
///     	json.EncodeRepo encoder(_) => new json.EncodeRepo(repo);
///
///     	@Get()
///     	@WrapOne(#encoder)
///     	Book get(Context ctx) => new Book.fromNum(5);
///
///     	@Get(path: '/many')
///     	@WrapOne(#encoder)
///     	List<Book> getList(Context ctx) =>
///     			new List<Book>.generate(5, (int i) => new Book.fromNum(i));
///     }
class EncodeRepo extends Interceptor {
  /// Repository used to decode and encode JSON
  final JsonRepo repo;

  EncodeRepo(this.repo);

  Null pre(_) => null;

  Response<String> post(Context ctx, Response<dynamic> incoming) {
    Response<String> resp = new Response<String>.cloneExceptValue(incoming);
    resp.value = repo.serialize(incoming.value, withType: true);
    resp.headers.mimeType = ContentType.JSON.mimeType;
    return resp;
  }
}

/// Interceptor to decode Dart object of type [ModelType] from JSON HTTP body.
///
/// Uses [repo] to deserialize Dart objects.
///
///     @Api(path: '/api/book')
///     class BookRoutes {
///     	json.DecodeRepo decoder(_) => new json.DecodeRepo(repo);
///
///     	json.Encode<Book> encoder(_) => new json.Encode<Book>(bookSerializer);
///
///     	@Post()
///     	@Wrap(const [#decoder, #encoder])
///     	Book get(Context ctx) => ctx.getInterceptorResult(json.DecodeRepo);
///
///     	@Post(path: '/many')
///     	@Wrap(const [#decoder, #encoder])
///     	List<Book> getList(Context ctx) => ctx.getInterceptorResult(json.DecodeRepo);
///     }
class DecodeRepo extends Interceptor {
  /// Repository used to decode and encode JSON
  final JsonRepo repo;

  final Encoding encoding;

  DecodeRepo(this.repo, {this.encoding: UTF8});

  Future<dynamic> pre(Context ctx) async {
    String data = await ctx.req.bodyAsText(encoding);
    if (data.isNotEmpty) {
      return repo.deserialize(data);
    }

    return null;
  }
}
