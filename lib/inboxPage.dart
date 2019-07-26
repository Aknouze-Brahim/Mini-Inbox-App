import 'package:flutter/material.dart';
import 'package:sign_in_flutter/sign_in.dart';
import 'package:sign_in_flutter/login_page.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:sign_in_flutter/firebase_database_util.dart';
import 'package:sign_in_flutter/data/classes/email.dart';
import 'package:sign_in_flutter/Widgets/beautiful_alert_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'contact.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:positioned_tap_detector/positioned_tap_detector.dart';

class Item {
  final String key;
  String destination;
  String sujet;
  String contenu;
  String origine;
  String category;
  String date;
  String lu; bool favorite;

  Item(this.key, this.origine, this.destination,
      this.sujet, this.contenu, this.category, this.date, this.lu, this.favorite);

  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        origine = snapshot.value["origine"],
      destination = snapshot.value["destination"],
          sujet = snapshot.value["sujet"],
  contenu = snapshot.value["contenu"],
        category = snapshot.value["category"],
        date = snapshot.value["date"],
        lu = snapshot.value["lu"],
  favorite = snapshot.value["favorite"];


  toJson() {
    return {
      "origine": origine,
      "destination": destination,
      "sujet": sujet,
      "contenu" : contenu,
      "category" : category,
      "date" : date,
      "lu": lu,
      "favorite": favorite
    };
  }
}

class InboxPage extends StatefulWidget {
  InboxPage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  InboxPageState createState() => InboxPageState();
}

class InboxPageState extends State<InboxPage> {
  List<Item> items = List();
  Item item;
  DatabaseReference itemRef;
  String _category = "Boîte de réception"; bool _origine; bool _destination;

  var drawerIcons = [
    //Icon(Icons.move_to_inbox),
    Icon(Icons.inbox),
    Icon(Icons.star),
    Icon(Icons.people),
    Icon(Icons.send),
    Icon(Icons.date_range),
    Icon(Icons.delete),
    Icon(Icons.settings),
    Icon(Icons.exit_to_app),
  ];

  var drawerText = [
    ["Boîte de réception",false,true],
  ["Marqués",false,false],
    ["Contacts",true,true],
    ["Envoyés",true,false],
    ["Brouillon",true,false],
    ["Corbeille",false,false],
    ["Settings",true,true],
    ["Déconnecter",true,true]
  ];

  var titleBarContent = "Boîte de réception";
  List<String> allData = [];   bool _anchorToBottom = false;
  FirebaseDatabaseUtil databaseUtil;

  //////////////////////////////////////////
  Widget UI(String message) {
    return new Card(
      elevation: 10.0,
      child: new Container(
        padding: new EdgeInsets.all(20.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text('Name : name',style: Theme.of(context).textTheme.title,),
            new Text('Message : $message'),
          ],
        ),
      ),
    );
  }
  //////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    print ('meeeeee '+ Contact.contacts.values.toString());

    return Scaffold(
      appBar: _getMailAppBar(),
      drawer: _getMailAccountDrawerr(),
      body: //_mailListViewGenerator()


      /*new FutureBuilder(
          future: Getdata(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {*/

                /*return new Container(
                        child: allData.length == 0
                            ? new Text(' No Data is Available')
                            : new ListView.builder(
                          itemCount: allData.length,
                          itemBuilder: (_, index) {
                            return UI(
                              allData[index],
                            );
                          },
                        ));*/
      (_category != "Contacts" && _category != "Settings") ? new FirebaseAnimatedList(
                  key: new ValueKey<bool>(_anchorToBottom),
                  query: databaseUtil.getUser(),
                  reverse: _anchorToBottom,
                  sort: _anchorToBottom
                      ? (DataSnapshot a, DataSnapshot b) => b.key.compareTo(a.key)
                      : null,
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    Email emailItem = Email.fromSnapshot(snapshot);
                    if(_origine == false && _destination == true) {
                      // boîte de réception
                      if (emailItem.category == _category &&
                          emailItem.destination == email) {
                        print('rgrgrgrgrg ${emailItem.favorite}');
                        return new SizeTransition(
                          sizeFactor: animation,
                          child: showUser(snapshot),
                        );
                      }
                      else {
                        return new SizeTransition(
                          sizeFactor: animation,
                          child: Container(width: 0, height: 0),
                        );
                      }
                    }
                    else{
                      if(_origine == false && _destination == false) {
                        if(_category == "Marqués") {
                          // les messages marqués
                          if (emailItem.favorite == true) {
                            return new SizeTransition(
                              sizeFactor: animation,
                              child: showUser(snapshot),
                            );
                          }
                          else {
                            return new SizeTransition(
                              sizeFactor: animation,
                              child: Container(width: 0, height: 0),
                            );
                          }
                        }
                        else{
                          // Corbeille
                          if (emailItem.category == "Corbeille") {
                            return new SizeTransition(
                              sizeFactor: animation,
                              child: showUser(snapshot),
                            );
                          }
                          else {
                            return new SizeTransition(
                              sizeFactor: animation,
                              child: Container(width: 0, height: 0),
                            );
                          }
                        }
                      }
                      else{
                        // les messages envoyés
                        if (emailItem.category == _category) {
                          return new SizeTransition(
                            sizeFactor: animation,
                            child: showUser(snapshot),
                          );
                        }
                        else {
                          return new SizeTransition(
                            sizeFactor: animation,
                            child: Container(width: 0, height: 0),
                          );
                        }
                        }
                    }

                  },
                )
      : Center(child: Text("Page de '"+_category+"'"))
      ,

             /* } else {
                return new CircularProgressIndicator();
              }
            }
          },
      ),*/



      floatingActionButton: _getMailFloatingActionButton(),
    );
  }

  Widget showUser(DataSnapshot res) {
    Email emailItem = Email.fromSnapshot(res);
    bool Modify;
    (emailItem.category == "Brouillon") ? Modify = true : Modify = false;

    var item = PositionedTapDetector(
      onLongPress: (TapPosition position){
        final RenderBox overlay = Overlay.of(context).context.findRenderObject();
var dx = position.relative.dx + 2;
        Offset off = Offset(MediaQuery.of(context).size.width*0.05,position.relative.dy + 2);
        Offset off2 = Offset(MediaQuery.of(context).size.width*0.8,
            position.global.dy + MediaQuery.of(context).size.height*0.1);

        showMenu(
            context: context,
            items: <PopupMenuEntry<int>>[MenuEntry(emailItem)],
            position: RelativeRect.fromRect(
                (off2 & Size(3.0, 4.0)), // smaller rect, the touch area
                off & overlay.size   // Bigger rect, the entire screen
            )
        );
        },

      /*
          final RenderBox overlay = Overlay.of(context).context.findRenderObject();
          TapDownDetails details;
          final _controller = PositionedTapController();

          final RenderBox referenceBox = context.findRenderObject();
Offset _tapPosition;
          _tapPosition = _controller.onLongPress;
              //referenceBox.globalToLocal(details.globalPosition);
print('nnnnnoooo'+_tapPosition.toString());
          showMenu(
              context: context,
              items: <PopupMenuEntry<int>>[PlusMinusEntry()],
              position: RelativeRect.fromRect(
                  (Offset(1.0, 2.0) & Size(3.0, 4.0)), // smaller rect, the touch area
                  Offset.zero & overlay.size   // Bigger rect, the entire screen
              )
          )
          // This is how you handle user selection
              .then<void>((int delta) {
            // delta would be null if user taps on outside the popup menu
            // (causing it to close without making selection)
            if (delta == null) return;

            /*setState(() {
              _count = _count + delta;
            });*/
          });
      }, */

          onTap: (TapPosition position) {
        Navigator.push(
          context,
          MaterialPageRoute(builder:
              (context) => ShowEmailPage(Modify,itemRef, emailItem))
        );
        Email Anemail = Email();
        Anemail.key = emailItem.key;
        Anemail.contenu =emailItem.contenu;
        Anemail.date =emailItem.date;
        Anemail.destination =emailItem.destination;
        Anemail.origine =emailItem.origine;
        Anemail.description =emailItem.description;
        Anemail.favorite = emailItem.favorite;
        Anemail.sujet =emailItem.sujet;
        Anemail.category =emailItem.category;
        Anemail.lu = true;
        databaseUtil.updateUser(Anemail);
      },
      child:
    new Card(
      child:
        new Container(
          color: (emailItem.lu == false) ?
          Color(0xFF0D6374).withOpacity(0.2)
          : Colors.transparent,
          padding: EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: CircleAvatar(
                  radius: 25.0,
                  child: Icon(Icons.email, color: Colors.orange,),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        emailItem.sujet ?? "",
                        style: Theme.of(context).textTheme.display1.copyWith(
                            fontSize: 16.0,
                            fontWeight: (emailItem.lu == false) ? FontWeight.w800 : FontWeight.w500
                        ),
                      ),

                      Text(
                        emailItem.contenu ?? "",
                        maxLines: 3,
                        style: Theme.of(context).textTheme.body1.copyWith(
                          fontSize: 16.0,
                          color: Colors.grey,
                          fontWeight: (emailItem.lu == false) ? FontWeight.w700 : FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(DateFormat.jm().format(DateTime.parse(emailItem.date)),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: (emailItem.lu == false) ?
                    FontWeight.w700 : FontWeight.w500),
                  ),
                  Text(DateFormat.yMd().format(DateTime.parse(emailItem.date)),
                    style: TextStyle(fontWeight: (emailItem.lu == false) ?
                    FontWeight.w700 : FontWeight.w500),
                  ),
                  IconButton(
                    icon: (emailItem.favorite != false)
                        ? Icon(Icons.star, color: Colors.amber)
                        : Icon(Icons.star_border),
                    onPressed: () {
                      Email Anemail = Email();
                          Anemail.key = emailItem.key;
                      Anemail.contenu =emailItem.contenu;
                      Anemail.date =emailItem.date;
                      Anemail.destination =emailItem.destination;
                      Anemail.origine =emailItem.origine;
                      Anemail.description =emailItem.description;
                      Anemail.favorite = !emailItem.favorite;
                      Anemail.sujet =emailItem.sujet;
                      Anemail.category =emailItem.category;
                      Anemail.lu =emailItem.lu;
                      databaseUtil.updateUser(Anemail);

                    },
                  ),
                ],
              ),
            ],
          ),
        ),

      /*new Container(
          child: new Center(
            child: new Row(
              children: <Widget>[
                new CircleAvatar(
                  radius: 30.0,
                  child: new Text(emailItem.sujet),
                  backgroundColor: const Color(0xFF20283e),
                ),
                new Expanded(
                  child: new Padding(
                    padding: EdgeInsets.all(10.0),
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                          "emailItem.contenu",
                          // set some style to text
                          style: new TextStyle(
                              fontSize: 20.0, color: Colors.lightBlueAccent),
                        ),
                        new Text(
                          emailItem.contenu,
                          // set some style to text
                          style: new TextStyle(
                              fontSize: 20.0, color: Colors.lightBlueAccent),
                        ),
                        new Text(
                          "emailItem",
                          // set some style to text
                          style: new TextStyle(
                              fontSize: 20.0, color: Colors.amber),
                        ),
                      ],
                    ),
                  ),
                ),
                new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                   /* new IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: const Color(0xFF167F67),
                      ),
                      onPressed: () => showEditWidget(emailItem, true),
                    ),*/
                    new IconButton(
                      icon: const Icon(Icons.delete_forever,
                          color: const Color(0xFF167F67)),
                      onPressed: () => deleteUser(emailItem),
                    ),
                  ],
                ),
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0)
      ),
        */
    ),
    )
    ;

    return item;
  }
  /*showEditWidget(Email emailItem, bool isEdit) {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          new AddUserDialog().buildAboutDialog(context, this, isEdit, email),
    );
  }*/

  deleteUser(Email emailItem) {
    setState(() {
      databaseUtil.deleteUser(emailItem);
    });
  }
  //////////////////////////////////////////////////////////////////////////

  void initState() {
    super.initState();

    databaseUtil = new FirebaseDatabaseUtil();
    databaseUtil.initState();

    item = Item("", "","","","","","",null,false);
   // final FirebaseDatabase database = FirebaseDatabase.instance; //Rather then just writing FirebaseDatabase(), get the instance.
    // itemRef = database.reference().child('items');

    /*final DatabaseReference ref = FirebaseDatabase.instance.reference();
    ref.child('items').once().then((DataSnapshot snap) {
      var keys = snap.value.keys;
      print(keys.toString());
      var data = snap.value;
      allData.clear();
      for (var key in keys) {
        String d =
        data[key]['contenu'];
        allData.add(d);
      }
    });*/

    //itemRef.onChildAdded.listen(_onEntryAdded);
    //itemRef.onChildChanged.listen(_onEntryChanged);
  }

  FloatingActionButton _getMailFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Email Anemail = Email();
        Anemail.destination = "";
        Anemail.contenu = "";
        Anemail.sujet = "";
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ComposeEmailPage(itemRef, Anemail)),
        );
      },
      child: Icon(Icons.email),
      backgroundColor: Color(0xFF0D6374),
      // Color(0xFFEC8C59),
    );
  }

  AppBar _getMailAppBar() {
    return AppBar(
      backgroundColor: //Color(0xFFFA5D00),
      Color(0xFF0D6374),
      title: new Text(
        //titleBarContent,
        "",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w400,
        ),
      ),
      actions: <Widget>[
        Container(
          padding: const EdgeInsets.only(right: 13.0),
          alignment: Alignment.center,
          child: new Text(
          titleBarContent,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.w400,
          ),
        ),),
        /*Padding(
          padding: const EdgeInsets.only(right: 13.0),
          child: Icon(
            Icons.search,
            size: 25.0,
          ),
        ),*/
      ],
    );
  }

  Drawer _getMailAccountDrawerr() {
    Text Myemail = new Text(
        email,
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15.0),
    );

    Text Myname = new Text(
      name,
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15.0),
    );

    return Drawer(
        child: Column(
      children: <Widget>[
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: Color(0xFF0D6374)),
          //Color(0xFFFA5D00)),
          accountName: Myname,
          accountEmail: Myemail,
          currentAccountPicture:
          CircleAvatar(
            backgroundImage: NetworkImage(
              imageUrl,
            ),
            radius: 60,
            backgroundColor: Colors.transparent,
          ),
          /*Icon(
            Icons.account_circle,
            size: 50.0,
            color: Colors.white,
          ),*/
        ),
        Expanded(
          flex: 2,
          child: ListView.builder(
              padding: EdgeInsets.only(top:0.0),
              itemCount: drawerText.length,
              itemBuilder: (context, position) {
                return ListTile(
                  leading: drawerIcons[position],
                  title: Text(drawerText[position][0],
                      style: TextStyle(fontSize: 15.0)),
                  onTap: () {
                    if((drawerText[position][0]) != "Déconnecter")
                    {this.setState(() {
                      titleBarContent = drawerText[position][0];
                      _category = drawerText[position][0];
                      _origine = drawerText[position][1];
                      _destination = drawerText[position][2];
                    });
                    Navigator.pop(context);}
                    else{
                      signOutGoogle();
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {return LoginPage();}), ModalRoute.withName('/'));

                    }
                  },
                );
              }),
        )
      ],
    ));
  }


  /*Future<int> Getdata() async{
    final DatabaseReference ref = FirebaseDatabase.instance.reference();
    ref.child('items').once().then((DataSnapshot snap) {
      var keys = snap.value.keys;
      print(keys.toString());
      var data = snap.value;
      allData.clear();
      for (var key in keys) {
        String d =
        data[key]['contenu'];
        allData.add(d);}
    });
    return 1;}*/

}

class ComposeEmailPage extends StatefulWidget {
  DatabaseReference itemRef; Email emailItem;

  ComposeEmailPage(this.itemRef, this.emailItem, {Key key}) : super(key: key);

  @override
  ComposeEmailPageState createState() => ComposeEmailPageState(this.itemRef, this.emailItem);
}

class ComposeEmailPageState extends State<ComposeEmailPage> {
  DatabaseReference itemRef; Email emailItem;
  Item item;
  List<Item> items = List();
  TextEditingController DestinationController = TextEditingController();
  TextEditingController SujetController = TextEditingController();
  TextEditingController ContenuController = TextEditingController();

  String _email;

  final List<String> kWords ;
  static List<String> words ;
  static var list = (Contact.contacts).values.toSet();

  //= [email];
  AutoCompleteTextField searchTextField;
  GlobalKey<AutoCompleteTextFieldState<Contacts>> key = new GlobalKey();

  //ComposeEmailPageState(this.itemRef);
  ComposeEmailPageState(this.itemRef, this.emailItem)
      : kWords = List.from(Set.from(list))
    ..sort(
          (w1, w2) => w1.toLowerCase().compareTo(w2.toLowerCase()),
    ),
        super();

  void _loadData() async {
    await ContactsViewModel.loadContacts();
  }
  @override
  void initState() {
    super.initState();
    _loadData();
    print(ContactsViewModel.contacts.toString());
    DestinationController.text = emailItem.destination;
    ContenuController.text = emailItem.contenu;
    SujetController.text = emailItem.sujet;

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF0D6374),
          //Color(0xFFFA5D00),
          leading: GestureDetector(
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Icon(Icons.arrow_back, color: Colors.white, size: 25.0),
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          title: new Text(
            "Nouveau message",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.access_time, size: 25,),
              onPressed: () {
                handleSubmit(context,"Brouillon","Sauvegarde","Le message a été sauvegardé");
              },

            ),
            IconButton(
              icon: Icon(Icons.send, size: 25,),
              onPressed: () {
                handleSubmit(context,"Envoyés","Envoi","Le message a été envoyé");

              },
            ),
          ],
        ),
        body:
            ListView(
              children: <Widget>[
        Column(
          children: <Widget>[
            SizedBox(height: 10),
            //new Column(children: <Widget>[
          searchTextField = AutoCompleteTextField<Contacts>(
            controller: DestinationController,
              keyboardType: TextInputType.emailAddress,
                style: new TextStyle(color: Colors.black, fontSize: 16.0),
                decoration: new InputDecoration(
                    suffixIcon: Container(
                      width: 85.0,
                      height: 60.0,
                    ),
                    contentPadding: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 20.0),
                    filled: true,
                    hintText: 'Destinataire :',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.8))),
                itemSubmitted: (item) {
                  setState(() => searchTextField.textField.controller.text =
                      item.adresse);
                },
                clearOnSubmit: false,
                key: key,
                suggestions: ContactsViewModel.contacts,
                itemBuilder: (context, item) {
                  return
                    Stack( children: <Widget>[
                    Align(alignment: Alignment(200, 500),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(item.adresse,
                        style: TextStyle(
                            fontSize: 16.0
                        ),),
                      Padding(
                        padding: EdgeInsets.all(15.0),
                      ),
                      Text(item.name,
                      )
                    ],
                  )
                  )
    ]);
                },
                itemSorter: (a, b) {
                  return a.adresse.compareTo(b.adresse);
                },
                itemFilter: (item, query) {
                  return item.adresse
                      .toLowerCase()
                      .startsWith(query.toLowerCase());
                }),
            //]),
            ///////////////////////////////////////////////////
            /*ListTile(
              title:
                  InkWell(
                    onTap: (){showSearch(
                      context: context,
                      delegate: _searchDelegate,
                    );},
              child: TextFormField(
                controller: DestinationController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => !EmailValidator.Validate(val, true)
                      ? 'adresse invalide'
                      : null,
                  autovalidate: true,
                  onEditingComplete: (){ },
                  decoration: InputDecoration(
                      labelText: "Destinataire : ",
                      border: InputBorder.none,
                      labelStyle:
                          TextStyle(color: Colors.black54, fontSize: 18.0))
              ),
    ),
              trailing: Icon(Icons.keyboard_arrow_down),
            ),*/
            //SizedBox(height: 5,),
            Divider(),
            ListTile(
              title: TextFormField(
                controller: SujetController,
                  onEditingComplete: (){ },
                  decoration: InputDecoration(
                      hintText: "Sujet : ",
                      border: InputBorder.none,
                      hintStyle:
                          TextStyle(color: Colors.black54, fontSize: 18.0))),
            ),
            Divider(),
            SizedBox(height: 10,),
             ListTile(
                title:
                    Container(width: MediaQuery.of(context).size.width*0.94,
                  child:
                TextField(
                    maxLines: null,
                    controller: ContenuController,
                    maxLengthEnforced: false,
                    decoration: InputDecoration(
                  hintText: "Saisir le contenu du message",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black54, fontSize: 18.0),
                )),),

              ),
            Divider(),
          ],
        ),
              ]),
    //),
        );
    //);
  }

  void handleSubmit(BuildContext context, String category, String title,String mes) {

    if(DestinationController.text != "")
{
  String now = new DateTime.now().toString();
  //item = Item("",email,DestinationController.text, SujetController.text,ContenuController.text, category, now, null, false);
    //final FirebaseDatabase database = FirebaseDatabase.instance; //Rather then just writing FirebaseDatabase(), get the instance.
  //itemRef = database.reference().child('items').child(email.replaceAll('@', " at ").replaceAll(".", " point "));
  //itemRef.onChildAdded.listen(_onEntryAdded);
    //itemRef.onChildChanged.listen(_onEntryChanged);
    //itemRef.push().set(item.toJson());

  Email Anemail = Email();
  Anemail.contenu =ContenuController.text;
  Anemail.date =now;
  Anemail.destination =DestinationController.text;
  Anemail.origine =email;
  Anemail.sujet =SujetController.text;
  Anemail.category =category;

  FirebaseDatabaseUtil databaseUtil = new FirebaseDatabaseUtil();
  databaseUtil.initState();
  databaseUtil.addUser(Anemail, category,DestinationController.text);

  if(emailItem.key != null){
      Email Anemail = Email();
      Anemail.key = emailItem.key;
      databaseUtil.deleteUser(Anemail);

  }

    Navigator.of(context).pop();

    _alertDialog(context,mes,title);}
    else{
      _alertDialog2(context,"aucune adresse n'est saisie","Attention !");
    }

    }

  _alertDialog2(BuildContext context,String mes,String title) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 4), () {
            Navigator.of(context).pop(true);
          });
          return BeautifulAlertDialog(false,title,mes);
        }
    );
  }

  _alertDialog(BuildContext context,String mes,String title) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 3), () {
            Navigator.of(context).pop(true);
          });
          return BeautifulAlertDialog(false,title,mes);
        }
    );
  }
  _onEntryAdded(Event event) {
    //setState(() {
      items.add(Item.fromSnapshot(event.snapshot));
      //itemRef2 = database.reference().child('items').child(email.replaceAll('@', " at ").replaceAll(".", " point "));
      items.add(Item.fromSnapshot(event.snapshot));

      print(Item.fromSnapshot(event.snapshot).key);

    //});
  }

  _onEntryChanged(Event event) {
    var old = items.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    //setState(() {
      items[items.indexOf(old)] = Item.fromSnapshot(event.snapshot);
    //});
  }
}

/////////////////////////////////////////////////////////////////

class ShowEmailPage extends StatefulWidget {
  bool Modify;
  DatabaseReference itemRef; Email emailItem;
  ShowEmailPage(this.Modify, this.itemRef, this.emailItem, {Key key}) : super(key: key);

  @override
  ShowEmailPageState createState() => ShowEmailPageState(this.Modify, this.itemRef, this.emailItem);
}

class ShowEmailPageState extends State<ShowEmailPage> {
  bool Modify;
  DatabaseReference itemRef; Email emailItem;
  Item item;
  List<Item> items = List();

  String _email;

  static var list = (Contact.contacts).values.toSet();

  AutoCompleteTextField searchTextField;
  GlobalKey<AutoCompleteTextFieldState<Contacts>> key = new GlobalKey();

  ShowEmailPageState(this.Modify, this.itemRef, this.emailItem) : super();


  void _loadData() async {
    await ContactsViewModel.loadContacts();
  }
  @override
  void initState() {
    super.initState();
    _loadData();
    print(ContactsViewModel.contacts.toString());

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0D6374).withOpacity(0.35),
        //Color(0xFFFA5D00),
        leading: GestureDetector(
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Icon(Icons.arrow_back, color: Colors.white, size: 25.0),
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        title: new Text(
          "",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: <Widget>[
          (Modify == true) ? IconButton(
            icon: Icon(Icons.edit, size: 25,),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ComposeEmailPage(itemRef,emailItem)),
              );
            },

          ) : Container(width: 0,height: 0,),
       IconButton(
            icon: Icon(Icons.delete, size: 25,),
            onPressed: () {
                FirebaseDatabaseUtil databaseUtil = new FirebaseDatabaseUtil();
                databaseUtil.initState();
                if( emailItem.category == "Corbeille" || emailItem.category == "Brouillon") {
                  Email Anemail = Email();
                  Anemail.key = emailItem.key;
                  databaseUtil.deleteUser(Anemail);
                }
                else{
                  Email Anemail = Email();
                  Anemail.key = emailItem.key;
                  Anemail.contenu =emailItem.contenu;
                  Anemail.date =emailItem.date;
                  Anemail.destination =emailItem.destination;
                  Anemail.origine =emailItem.origine;
                  Anemail.favorite = emailItem.favorite;
                  Anemail.sujet =emailItem.sujet;
                  Anemail.category ="Corbeille";
                  Anemail.lu =emailItem.lu;
                  databaseUtil.updateUser(Anemail);
                }

                Navigator.of(context).pop();
    _alertDialog(context,"Suppression du message effectuée","suppression");

            },
          ),
        ],
      ),
      body:
      ListView(
          children: <Widget>[

          Container(
            padding: EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    emailItem.sujet ?? "",
                    maxLines: 2,
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                IconButton(
                  icon: (emailItem.favorite ?? false)
                      ? Icon(Icons.star, color: Colors.amber)
                      : Icon(Icons.star_border),
                  onPressed: (){},
                ),
              ],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 2.0, color: Colors.blueGrey.shade600),
                bottom: BorderSide(width: 2.0, color: Colors.blueGrey.shade900),
                right: BorderSide(width: 4.0, color: Colors.blueGrey.shade900),
                left: BorderSide(width: 4.0, color: Colors.blueGrey.shade900),
              ),
              color: Colors.white,
            ),
            padding: EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    'De : '+emailItem.destination+'\n''à : '+emailItem.origine,
                    style: TextStyle(color: Colors.black.withOpacity(0.5)),
                  ),
                ),
                Text(
    DateFormat.yMd().format(DateTime.parse(emailItem.date)) +'\n'
    + DateFormat.jm().format(DateTime.parse(emailItem.date)),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12,),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(18.0),
            child: Text(emailItem.contenu, maxLines: null, style: TextStyle(fontSize: 16)),
          ),


          ]),
      //),
    );
    //);
  }

  _alertDialog2(BuildContext context,String mes,String title) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 4), () {
            Navigator.of(context).pop(true);
          });
          return BeautifulAlertDialog(false,title,mes);
        }
    );
  }

  _alertDialog(BuildContext context,String mes,String title) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 3), () {
            Navigator.of(context).pop(true);
          });
          return BeautifulAlertDialog(false,title,mes);
        }
    );
  }

}

class MenuEntry extends PopupMenuEntry<int> {
  Email TheEmail;

  MenuEntry(this.TheEmail);
  @override
  double height = 100;
  // height doesn't matter, as long as we are not giving
  // initialValue to showMenu().

  @override
  bool represents(int n) => n == 1 || n == -1;

  @override
  MenuEntryState createState() => MenuEntryState(this.TheEmail);
}

class MenuEntryState extends State<MenuEntry> {
  Email TheEmail;
  MenuEntryState(this.TheEmail);


  void _delete() {
    FirebaseDatabaseUtil databaseUtil = new FirebaseDatabaseUtil();
    databaseUtil.initState();
    if( TheEmail.category == "Corbeille" || TheEmail.category == "Brouillon") {
      Email Anemail = Email();
      Anemail.key = TheEmail.key;
      databaseUtil.deleteUser(Anemail);
    }
    else{
      Email Anemail = Email();
      Anemail.key = TheEmail.key;
      Anemail.contenu =TheEmail.contenu;
      Anemail.date =TheEmail.date;
      Anemail.destination =TheEmail.destination;
      Anemail.origine =TheEmail.origine;
      Anemail.description =TheEmail.description;
      Anemail.favorite = TheEmail.favorite;
      Anemail.sujet =TheEmail.sujet;
      Anemail.category ="Corbeille";
      Anemail.lu =TheEmail.lu;
      databaseUtil.updateUser(Anemail);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: FlatButton(
            onPressed: _delete, child: Text('supprimer'))),
      ],
    );
  }
}