# jaguar_json

This package provides jaguar_serializer based interceptors, utitity methods and utility classes for Jaguar to make
encoding and decoding JSON easier.

# Interceptors

jaguar_json exposes interceptors to encode and decode Dart objects to and from JSON using two methods:

1. Using `Serializer`
2. Using `JsonRepo`

## Using `Serializer`

`Encode`, `Decode` and `Codec` interceptors are provided to encode and decode json. Both these interceptors
accept an instance of the `Serializer<ModelType>` class that it internally uses to serialize and
deserialize.

`Encode` automatically serializes result returned from the route method. Care must be taken that the
route returns an object of type `ModelType`.

`Decode` automatically de-serializes JSON body in the request to `ModelType`. The de-serialized dart
object can be obtained in the route method using `ctx.getInput(Decode)`.

```dart
@Api(path: '/api/book')
class BookRoutes {
  json.Decode decoder(_) => new json.Decode(bookSerializer);

  json.Encode<Book> encoder(_) => new json.Encode<Book>(bookSerializer);

  @Post()
  @Wrap(const [#decoder, #encoder])
  Book one(Context ctx) {
    final Book book = ctx.getInput(json.Decode);
    return book;
  }

  @Post(path: '/many')
  @Wrap(const [#decoder, #encoder])
  List<Book> list(Context ctx) => ctx.getInput(json.Decode);
}
```

## Using `JsonRepo`

Using `JsonRepo` simplifies the encoding and decoding. First task is to create a `JsonRepo` object
and add all the required serializers to it. 

`EncodeRepo`, `DecodeRepo` and `CodecRepo` interceptors are provided to encode and decode json using repo. Both these 
interceptors accept an instance of `JsonRepo` that it internally uses to find the appropriate serializer 
to serialize and deserialize. For the decoder to find the right serializer, the incoming JSON body must have a type
field. The type field can be set in the `DecodeRepo` using `typeKey` argument.

```dart
@Api(path: '/api/book')
class BookRoutes {
  json.CodecRepo codec(_) => new json.CodecRepo(repo);

  @Get()
  @WrapOne(#codec)
  Book get(Context ctx) => new Book.fromNum(5);

  @Post()
  @WrapOne(#codec)
  Book post(Context ctx) {
    final book = ctx.getInput<Book>(json.CodecRepo);
    return book;
  }
}
```

# `JsonRoutes` utility class

`Api`s can extend `JsonRoutes` class to get access to `toJson` and `fromJson` methods that using `JsonRepo` to make
encoding and decoding JSON easier.

```dart
@Api(path: '/api/book')
class BookRoutes extends Object with json.JsonRoutes {
  JsonRepo get repo => models.repo;

  @Get()
  Response<String> get(Context ctx) => toJson(new Book.fromNum(5));

  @Post()
  Future<Response<String>> post(Context ctx) async =>
      toJson(await fromJson(ctx));
}
```

# Utility functions

Global functions `serialize` and `deserialize` helps in encoding and decoding JSON using `Serializer`.

```dart
@Api(path: '/api/book')
class BookRoutes {
  @Get()
  Response<String> get(Context ctx) =>
      json.serialize(bookSerializer, new Book.fromNum(5));

  @Post()
  Future<Response<String>> post(Context ctx) async => json.serialize(
      bookSerializer, await json.deserialize(bookSerializer, ctx));
}
```