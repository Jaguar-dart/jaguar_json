// GENERATED CODE - DO NOT MODIFY BY HAND

part of models;

// **************************************************************************
// Generator: SerializerGenerator
// Target: class PersonSerializer
// **************************************************************************

abstract class _$PersonSerializer implements Serializer<Person> {
  Map toMap(Person model, {bool withType: false, String typeKey}) {
    Map ret = new Map();
    if (model != null) {
      if (model.id != null) {
        ret["id"] = model.id;
      }
      if (model.username != null) {
        ret["username"] = model.username;
      }
      if (model.email != null) {
        ret["email"] = model.email;
      }
      if (modelString() != null && withType) {
        ret[typeKey ?? defaultTypeInfoKey] = modelString();
      }
    }
    return ret;
  }

  Person fromMap(Map map, {Person model, String typeKey}) {
    if (map is! Map) {
      return null;
    }
    if (model is! Person) {
      model = createModel();
    }
    model.id = map["id"];
    model.username = map["username"];
    model.email = map["email"];
    return model;
  }

  String modelString() => "Person";
}

// **************************************************************************
// Generator: SerializerGenerator
// Target: class BookSerializer
// **************************************************************************

abstract class _$BookSerializer implements Serializer<Book> {
  Map toMap(Book model, {bool withType: false, String typeKey}) {
    Map ret = new Map();
    if (model != null) {
      if (model.id != null) {
        ret["id"] = model.id;
      }
      if (model.author != null) {
        ret["author"] = model.author;
      }
      if (model.name != null) {
        ret["name"] = model.name;
      }
      if (model.price != null) {
        ret["price"] = model.price;
      }
      if (modelString() != null && withType) {
        ret[typeKey ?? defaultTypeInfoKey] = modelString();
      }
    }
    return ret;
  }

  Book fromMap(Map map, {Book model, String typeKey}) {
    if (map is! Map) {
      return null;
    }
    if (model is! Book) {
      model = createModel();
    }
    model.id = map["id"];
    model.author = map["author"];
    model.name = map["name"];
    model.price = map["price"];
    return model;
  }

  String modelString() => "Book";
}
