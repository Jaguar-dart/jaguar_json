import 'dart:async';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_reflect/jaguar_reflect.dart';

import 'package:jaguar_json/jaguar_json.dart' as json;
import 'package:jaguar_client/jaguar_client.dart';

import '../../example/models/models.dart';

import '../../example/models/models.dart' as models;

final JsonRepo repo = new JsonRepo(
    serializers: [personSerializer, bookSerializer], withType: true);

@Api(path: '/api/book')
class BookRoutes extends Object with json.JsonRoutes {
  JsonRepo get repo => models.repo;

  @Get()
  Response<String> get(Context ctx) => toJson(new Book.fromNum(5));

  @Post()
  Future<Response<String>> post(Context ctx) async =>
      toJson(await fromJson(ctx));

  @Post(path: '/map')
  Future<Response<String>> map(Context ctx) async =>
      toJson(await fromJson(ctx));
}

@Api(path: '/api/person')
class PersonRoutes extends Object with json.JsonRoutes {
  JsonRepo get repo => models.repo;

  @Get()
  Response<String> get(Context ctx) => toJson(new Person.fromNum(5));

  @Post()
  Future<Response<String>> post(Context ctx) async =>
      toJson(await fromJson(ctx));
}

const String url = 'http://localhost:9080';

main() {
  group('Codec tests', () {
    final Jaguar server = new Jaguar(port: 9080);
    final j = new JsonClient(new http.Client(), repo: repo);

    setUpAll(() async {
      server.addApi(reflect(new BookRoutes()));
      server.addApi(reflect(new PersonRoutes()));
      await server.serve();
    });

    tearDownAll(() async {
      await server.close();
    });

    test('Decoding', () async {
      {
        final book1 = new Book.fromNum(1);
        final JsonResponse resp1 = await j.post(url + '/api/book', body: book1);
        expect(resp1.deserialize(), book1);
        expect(resp1.inner.headers['content-type'],
            'application/json; charset=utf-8');
      }

      {
        final person1 = new Person.fromNum(1);
        final JsonResponse resp1 =
            await j.post(url + '/api/person', body: person1);
        expect(resp1.deserialize(), person1);
      }
    });

    test('Encoding', () async {
      {
        final book5 = new Book.fromNum(5);
        final JsonResponse resp1 = await j.get(url + '/api/book');
        expect(resp1.deserialize(), book5);
        expect(resp1.inner.headers['content-type'],
            'application/json; charset=utf-8');
      }

      {
        final person5 = new Person.fromNum(5);
        final JsonResponse resp1 = await j.get(url + '/api/person');
        expect(resp1.deserialize(), person5);
      }
    });

    test('Raw Map', () async {
      {
        final body = <String, dynamic>{
          "field1": "string",
          "field2": 5,
          "@t": "Map",
        };
        final JsonResponse resp1 = await j.post(url + '/api/book', body: body);
        expect(resp1.deserialize(), {"field1": "string", "field2": 5});
        expect(resp1.inner.headers['content-type'],
            'application/json; charset=utf-8');
      }
    });

    test('Raw int', () async {
      {
        final body = 5;
        final JsonResponse resp1 = await j.post(url + '/api/book', body: body);
        expect(resp1.deserialize(), 5);
        expect(resp1.inner.headers['content-type'],
            'application/json; charset=utf-8');
      }
    });

    test('Raw String', () async {
      {
        final body = 'hello';
        final JsonResponse resp1 = await j.post(url + '/api/book', body: body);
        expect(resp1.deserialize(), 'hello');
        expect(resp1.inner.headers['content-type'],
            'application/json; charset=utf-8');
      }
    });
  });
}
