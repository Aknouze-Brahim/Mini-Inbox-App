import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';

class Contacts {
  final List<Person> contacts;

  Contacts({
    this.contacts,
  });

  factory Contacts.fromJson(List<dynamic> parsedJson) {

    List<Person> contacts = new List<Person>();
    contacts = parsedJson.map((i)=>Person.fromJson(i)).toList();

    return new Contacts(
        contacts: contacts
    );
  }
}

class Person {
  Map names;

  Person({
    this.names,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return new Person(
      names: json['names'],
    );
  }
  }
