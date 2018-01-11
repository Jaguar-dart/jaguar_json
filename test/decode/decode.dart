import 'package:test/test.dart';
import 'package:http/http.dart';

import 'package:jaguar/jaguar.dart';
import 'package:jaguar_reflect/jaguar_reflect.dart';

import 'package:jaguar_json/jaguar_json.dart' as json;
import 'package:jaguar_client/jaguar_client.dart';

import '../../example/models/models.dart';

@Api(path: '/api/book')
class BookRoutes {
  json.Decode decoder(_) => new json.Decode(bookSerializer);

  json.Encode<Book> encoder(_) => new json.Encode<Book>(bookSerializer);

  @Post()
  @Wrap(const [#decoder, #encoder])
  Book one(Context ctx) {
    final Book book = ctx.getInterceptorResult(json.Decode);
    return book;
  }

  @Post(path: '/many')
  @Wrap(const [#decoder, #encoder])
  List<Book> list(Context ctx) => ctx.getInterceptorResult(json.Decode);
}

@Api(path: '/api/person')
class PersonRoutes {
  json.Decode decoder(_) => new json.Decode(personSerializer);

  json.Encode<Person> encoder(_) => new json.Encode<Person>(personSerializer);

  @Post()
  @Wrap(const [#decoder, #encoder])
  Person one(Context ctx) => ctx.getInterceptorResult(json.Decode);

  @Post(path: '/many')
  @Wrap(const [#decoder, #encoder])
  List<Person> list(Context ctx) => ctx.getInterceptorResult(json.Decode);
}

const String url = 'http://localhost:9080';

main() {
  group('Decode tests', () {
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

    test('Decode', () async {
      {
        final book5 = new Book.fromNum(5);
        final JsonResponse resp1 = await j.post(url + '/api/book', body: book5);
        expect(resp1.deserialize(), book5);
        expect(resp1.inner.headers['content-type'],
            'application/json; charset=utf-8');
      }

      {
        final person5 = new Person.fromNum(5);
        final JsonResponse resp1 =
            await j.post(url + '/api/person', body: person5);
        expect(resp1.deserialize(), person5);
      }
    });

    test('Decode list', () async {
      {
        final books =
            new List<Book>.generate(5, (int i) => new Book.fromNum(i));
        final JsonResponse resp1 =
            await j.post(url + '/api/book/many', body: books);
        expect(resp1.deserialize(), books);
        expect(resp1.inner.headers['content-type'],
            'application/json; charset=utf-8');
      }

      {
        final persons =
            new List<Person>.generate(5, (int i) => new Person.fromNum(i));
        final JsonResponse resp1 =
            await j.post(url + '/api/person/many', body: persons);
        expect(resp1.deserialize(), persons);
      }
    });
  });
}
