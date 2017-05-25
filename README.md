# jaguar_json

jaguar_serializer based JSON interceptors for Jaguar

# Usage

Encoding and decoding using a `Serializer`

```dart
@RouteGroup()
class SerializerExample {
  WrapEncodeJson<Hello> helloEncoder() => new WrapEncodeJson<Hello>(helloCodec);
  WrapDecodeJson<MathInput> mathInputDecoder() =>
      new WrapDecodeJson<MathInput>(mathInputCodec);
  WrapEncodeJson<MathResult> mathResultEncoder() =>
      new WrapEncodeJson<MathResult>(mathResultCodec);

  @Get(path: '/hello')
  @Wrap(const [#helloEncoder])
  Hello sayHello() => new Hello()..greeting = "Hello";

  @Post(path: '/math')
  @Wrap(const [#mathResultEncoder, #mathInputDecoder])
  MathResult math(@Input(DecodeJson) MathInput input) {
    int a = input.a;
    int b = input.b;

    return new MathResult()
      ..addition = (a + b)
      ..subtraction = (a - b)
      ..mulitplication = (a * b)
      ..division = (a ~/ b);
  }
}
```

Encoding and decoding is a `SerializerRepo`

```dart
@RouteGroup()
@Wrap(const [#encoder, #decoder])
class RepoExample {
  WrapEncodeJsonRepo encoder() => new WrapEncodeJsonRepo(repo, withType: true);

  WrapDecodeJsonRepo decoder() => new WrapDecodeJsonRepo(repo);

  @Get(path: '/hello')
  Hello sayHello() => new Hello()..greeting = "Hello";

  @Post(path: '/math')
  MathResult math(@Input(DecodeJsonRepo) MathInput input) {
    int a = input.a;
    int b = input.b;

    return new MathResult()
      ..addition = (a + b)
      ..subtraction = (a - b)
      ..mulitplication = (a * b)
      ..division = (a ~/ b);
  }
}
```

# Intro

jaguar_json exposes interceptors to encode and decode Dart objects to and from JSON using two methods:

1. Using `Serializer`
2. Using `SerializerRepo`

## Using `Serializer`

`EncodeJson` and `DecodeJson` interceptors are provided to encode and decode json. Both these interceptors
accept an instance of the `Serializer<ModelType>` class that it internally uses to serialize and
deserialize.

`EncodeJson` automatically serializes result returned from the route method. Care must be taken that the
route returns an object of type `ModelType`.

`DecodeJson` automatically deserializes JSON body in the request to `ModelType`. The deserialized dart
object can be obtained in the route method using `@Input(DecodeJson)` injector.

## Using `SerializerRepo`

Using `SerializerRepo` simplifies the encoding and decoding. First task is to create a `JsonRepo` object
and add all the required serializers to it. 

`EncodeJsonRepo` and `DecodeJsonRepo` interceptors are provided to encode and decode json using repo. Both these 
interceptors accept an instance of the `JsonRepo` class that it internally uses to find the appropriate serializer 
to serialize and deserialize. For the decoder to find the right serializer, the incoming JSON body must have a type
field. The type field can be set in the `DecodeJsonRepo` using `typeKey` argument.

`EncodeJson` automatically serializes result returned from the route method.

`DecodeJson` automatically deserializes JSON body in the request to `ModelType`. The deserialized dart
object can be obtained in the route method using `@Input(DecodeJsonRepo)` injector.
