import 'package:test/test.dart';
import 'package:http/http.dart';

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_reflect/jaguar_reflect.dart';

import 'package:jaguar_json/jaguar_json.dart' as json;
import 'package:jaguar_client/jaguar_client.dart';

import '../../example/models/models.dart';

final JsonRepo repo = new JsonRepo(
    serializers: [personSerializer, bookSerializer], withType: true);

json.CodecRepo codec(_) => new json.CodecRepo(repo);

@Api(path: '/api/book')
class BookRoutes {
  @Get()
  @WrapOne(codec)
  Book get(Context ctx) => new Book.fromNum(5);

  @Post()
  @WrapOne(codec)
  Book post(Context ctx) {
    final book = ctx.getInterceptorResult<Book>(json.CodecRepo);
    return book;
  }
}

@Api(path: '/api/person')
class PersonRoutes {
  @Get()
  @WrapOne(codec)
  Person get(Context ctx) => new Person.fromNum(5);

  @Post()
  @WrapOne(codec)
  Person post(Context ctx) => ctx.getInterceptorResult<Person>(json.CodecRepo);
}

const String url = 'http://localhost:9080';

main() {
  group('CodecRepo tests', () {
    final Jaguar server = new Jaguar(port: 9080);
    final j = new JsonClient(new Client(), repo: repo);

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
  });
}
