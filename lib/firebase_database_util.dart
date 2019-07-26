import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
//import 'package:flutter_firebase_auth/user.dart';
import 'package:sign_in_flutter/data/classes/email.dart';
import 'package:sign_in_flutter/sign_in.dart';

class FirebaseDatabaseUtil {
  DatabaseReference _counterRef;
  DatabaseReference _userRef;
  DatabaseReference _userRef2;

  StreamSubscription<Event> _counterSubscription;
  StreamSubscription<Event> _messagesSubscription;
  FirebaseDatabase database = new FirebaseDatabase();
  int _counter;
  DatabaseError error;
  String category;

  static final FirebaseDatabaseUtil _instance =
      new FirebaseDatabaseUtil.internal();

  FirebaseDatabaseUtil.internal();

  factory FirebaseDatabaseUtil() {
    return _instance;
  }

  void initState() {
    // Demonstrates configuring to the database using a file
    //_counterRef = FirebaseDatabase.instance.reference().child('items');
    // Demonstrates configuring the database directly

    _userRef2 = database.reference().child('items');
    _userRef = database.reference().child('items').child(email.replaceAll('@', " at ").replaceAll(".", " point "));

    database.reference().child('items')
        /*.onValue
        .listen((Event event) {
      DataSnapshot name = event.snapshot;
      if (Email.fromSnapshot(name).origine == "aknouze1@gmail.com") {
        name = "";
      }
      onData(name);
    });*/
    .once().then((DataSnapshot snapshot) {
      print('Connected to second database and read ${snapshot.value}');
    });
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);
    _userRef2.keepSynced(true);
    _counterSubscription = _userRef2.onValue.listen((Event event) {
      error = null;
      //_counter = event.snapshot.value ?? 0;
    }, onError: (Object o) {
      error = o;
    });


  }

  DatabaseError getError() {
    return error;
  }

  int getCounter() {
    return _counter;
  }

  void setCategory(String category){
    this.category = category;
  }

  DatabaseReference getUser() {
    return _userRef;
  }

  addUser(Email emailItem,String category, String adresse) async {
    /*final TransactionResult transactionResult =
        await _userRef.runTransaction((MutableData mutableData) async {
      mutableData.value = (mutableData.value ?? 0) + 1;

      return mutableData;
    });
    print("hello 7");*/
    DatabaseReference _userRef3 = database.reference().child('items').child(adresse.replaceAll('@', " at ").replaceAll(".", " point "));

    /*final TransactionResult transactionResult2 =
    await _userRef3.runTransaction((MutableData mutableData) async {
      mutableData.value = (mutableData.value ?? 0) + 1;

      return mutableData;
    });
    print("hello 8");*/

    if (1 == 1) {
      _userRef.push().set(<String, dynamic>{
        "contenu": "" + emailItem.contenu,
        "origine": "" + emailItem.origine,
        "destination": "" + emailItem.destination,
        "sujet": "" + emailItem.sujet,
        "category": category,
        "lu": true,
        "favorite": false,
        "date": emailItem.date,
      }).then((_) {
        print('Transaction  effectuée.');
      });
    }
    /*else {
      print('Transaction not committed.');
      if (transactionResult.error != null) {
        print(transactionResult.error.message);
      }
    }*/
    print("hello 9");

    if(category == "Envoyés") {
      if (1 == 1) {
        _userRef3.push().set(<String, dynamic>{
          "contenu": "" + emailItem.contenu,
          "origine": "" + emailItem.origine,
          "destination": "" + emailItem.destination,
          "sujet": "" + emailItem.sujet,
          "category": "Boîte de réception",
          "lu": false,
          "favorite": false,
          "date": emailItem.date,
        }).then((_) {
          print('Transaction  effectuée.');
        });
      } /*else {
        print('Transaction not committed.');
        if (transactionResult.error != null) {
          print(transactionResult.error.message);
        }
      }*/
    }
  }

  void deleteUser(Email emailItem) async {
    await _userRef.child(emailItem.key).remove().then((_) {
      print('Transaction  effectuée.');
    });
  }

  void updateUser(Email emailItem) async {
    await _userRef.child(emailItem.key).update({
      "contenu": "" + emailItem.contenu,
      "origine": "" + emailItem.origine,
      "destination": "" + emailItem.destination,
      "sujet": "" + emailItem.sujet,
      "lu": emailItem.lu,
      "favorite": emailItem.favorite,
      "date": "" + emailItem.date,
      "category": "" + emailItem.category,
    }).then((_) {
      print('Transaction  effectuée');
    });
  }

  void dispose() {
    _messagesSubscription.cancel();
    _counterSubscription.cancel();
  }
}
