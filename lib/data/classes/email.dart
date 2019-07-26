import 'package:firebase_database/firebase_database.dart';

class EmailItem {
  EmailItem({
    this.avatar,
    this.date,
    this.description,
    this.favorite,
    this.title,
  });

  String title;

  String description;

  String avatar;
  DateTime date;

  bool favorite = false;
}

class Email {

  Email({
    this.key,
    this.contenu,
    this.date,
    this.destination,
    this.origine,
    this.description,
    this.favorite,
    this.sujet,
    this.category

  });
  String key;
  String sujet;
  String origine;
  String destination;
  String description;
  String contenu;
  String date;
  String category;
  bool favorite; bool lu;

  Email getEmail(String key, String contenu, String date, String destination,
      String origine, String description, bool favorite, String sujet, String category, bool lu){

  }
  Email.fromSnapshot(DataSnapshot snapshot) {
    key = snapshot.key;
    sujet = snapshot.value['sujet'];
    origine = snapshot.value['origine'];
    destination = snapshot.value['destination'];
    category = snapshot.value['category'];
    date = snapshot.value['date'];
    contenu = snapshot.value['contenu'];
    favorite = snapshot.value['favorite'];
    lu = snapshot.value['lu'];
  }
}
