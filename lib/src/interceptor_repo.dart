part of jaguar.json;

/// Interceptor to encode and decode JSlON
class CodecRepo extends Interceptor {
	final Encoding bodyEncoding;

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

class EncodeRepo extends Interceptor {
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

class DecodeRepo extends Interceptor {
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