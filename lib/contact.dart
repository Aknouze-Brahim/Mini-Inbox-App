import 'package:flutter/services.dart';

class Contact {

  static Map contacts = {};

}

class Contacts {
  String name;
  String adresse;

  Contacts({
    this.name,
    this.adresse
  });

  factory Contacts.fromJson(Map<String, dynamic> parsedJson) {
    return Contacts(
        name: parsedJson['name'] as String,
        adresse: parsedJson['adresse'] as String,
    );
  }
}

class ContactsViewModel {
  static List<Contacts> contacts = [];
  static Map contactsJson;

  static Future loadContacts() async{
    try {
      contacts = new List<Contacts>();
      Map parsedJson =
      {
        "contacts": [{
          "name": "Contact1",
          "adresse": "adresse1"
        }, {
          "name": "Contact2",
          "adresse": "adresse2"
        }, {
          "name": "Contact3",
          "adresse": "adresse3"
        }
        ]
      }
      ;
      var categoryJson = contactsJson['contacts'] as List;
      //print(categoryJson.toString());
      for (int i = 0; i < categoryJson.length; i++) {
        contacts.add(new Contacts.fromJson(categoryJson[i]));
      }
    }catch (e) {
  print(e);
  }

  }
}

