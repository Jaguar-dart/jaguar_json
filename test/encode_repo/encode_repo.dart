import 'package:test/test.dart';
import 'package:http/http.dart';

import 'package:jaguar/jaguar.dart';
import 'package:jaguar_reflect/jaguar_reflect.dart';

import 'package:jaguar_json/jaguar_json.dart' as json;
import 'package:jaguar_client/jaguar_client.dart';

import '../../example/models/models.dart';

json.EncodeRepo encoder(_) => new json.EncodeRepo(repo);

@Api(path: '/api/book')
class BookRoutes {
  @Get()
  @WrapOne(encoder)
  Book get(Context ctx) => new Book.fromNum(5);

  @Get(path: '/many')
  @WrapOne(encoder)
  List<Book> getList(Context ctx) =>
      new List<Book>.generate(5, (int i) => new Book.fromNum(i));
}

@Api(path: '/api/person')
class PersonRoutes {
  @Get()
  @WrapOne(encoder)
  Person get(Context ctx) => new Person.fromNum(5);

  @Get(path: '/many')
  @WrapOne(encoder)
  List<Person> getList(Context ctx) =>
      new List<Person>.generate(5, (int i) => new Person.fromNum(i));
}

const String url = 'http://localhost:9080';

main() {
  group('EncodeRepo tests', () {
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

    test('Encode list', () async {
      {
        final books =
            new List<Book>.generate(5, (int i) => new Book.fromNum(i));
        final JsonResponse resp1 = await j.get(url + '/api/book/many');
        expect(resp1.deserialize(), books);
        expect(resp1.inner.headers['content-type'],
            'application/json; charset=utf-8');
      }

      {
        final persons =
            new List<Person>.generate(5, (int i) => new Person.fromNum(i));
        final JsonResponse resp1 = await j.get(url + '/api/person/many');
        expect(resp1.deserialize(), persons);
      }
    });
  });
}
