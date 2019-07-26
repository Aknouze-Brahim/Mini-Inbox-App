// Copyright (c) 2019 Souvik Biswas

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/people/v1.dart';

import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'dart:convert';
import 'dart:io';
import 'package:sign_in_flutter/contact.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

String name;
String email;
String imageUrl;

Future<String> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
  await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final FirebaseUser user = await _auth.signInWithCredential(credential);

  // Checking if email and name is null
  assert(user.email != null);
  assert(user.displayName != null);
  assert(user.photoUrl != null);

  name = user.displayName;
  email = user.email;
  imageUrl = user.photoUrl;

  // Only taking the first part of the name, i.e., First Name
  /* if (name.contains(" ")) {
    name = name.substring(0, name.indexOf(" "));
  } */

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  ///////////////////////////////////////
  final authHeaders = await googleSignIn.currentUser.authHeaders;
  final httpClient = new GoogleHttpClient(authHeaders);
  var data = await new PeopleApi(httpClient).people.connections.list(
    'people/me',
    personFields: 'names,emailAddresses',
    //pageToken: 'nextPageToken',
    pageSize: 100,
  );

  List<Person> connections = data.connections;
  ///////////////////////////////////////
  Map map = new Map(); List Mylist = [];
  for (var i = 0; i < connections.length; i++) {
    String cont = '${(connections[i].emailAddresses.first.toJson())['value']
        .toString()}';
    String name = '${(connections[i].names.first.toJson())['displayName']
        .toString()}';
  print('HIHI '+cont+' '+ name);
    map[name] = cont;
    Mylist.add({"name":name,"adresse":cont});
  }
  map["contacts"] = Mylist;
  ContactsViewModel.contactsJson = map;
  print (ContactsViewModel.contactsJson.toString());

  return 'signInWithGoogle avec succes : $user';
}

void signOutGoogle() async{
  await googleSignIn.signOut();

  print("Sign Out");
}

class GoogleHttpClient extends IOClient {
  Map<String, String> _headers;

  GoogleHttpClient(this._headers) : super();

  @override
  Future<StreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<Response> head(Object url, {Map<String, String> headers}) =>
      super.head(url, headers: headers..addAll(_headers));

}

