library models;

import 'package:jaguar_serializer/serializer.dart';

part 'models.g.dart';

class Person {
  int id;

  String username;

  String email;

  Person();

  Person.make(this.id, this.username, this.email);

  factory Person.fromNum(int id) =>
      new Person.make(id, 'Username$id', 'Email$id');

  @override
  bool operator ==(final other) {
    if (other is Person) {
      return id == other.id &&
          username == other.username &&
          email == other.email;
    } else {
      return false;
    }
  }

  String toString() {
    return "Person(id: $id, username: $username, email: $email);";
  }
}

class Book {
  int id;

  String author;

  String name;

  int price;

  Book();

  Book.make(this.id, this.author, this.name, this.price);

  factory Book.fromNum(int id) =>
      new Book.make(id, 'Author$id', 'Name$id', id * 5);

  @override
  bool operator ==(final other) {
    if (other is Book) {
      return id == other.id &&
          author == other.author &&
          name == other.name &&
          price == other.price;
    } else {
      return false;
    }
  }

  @override
  String toString() {
    return 'Book(id: $id, author: $author, name: $name, price: $price);';
  }
}

@GenSerializer()
class PersonSerializer extends Serializer<Person> with _$PersonSerializer {
  @override
  Person createModel() => new Person();
}

@GenSerializer()
class BookSerializer extends Serializer<Book> with _$BookSerializer {
  @override
  Book createModel() => new Book();
}

final PersonSerializer personSerializer = new PersonSerializer();

final BookSerializer bookSerializer = new BookSerializer();

final JsonRepo repo =
    new JsonRepo(serializers: [personSerializer, bookSerializer]);
