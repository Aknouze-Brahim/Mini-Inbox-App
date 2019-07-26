import 'package:flutter/material.dart';
class BeautifulAlertDialog extends StatelessWidget {
  bool buttons; String title; String message;
  BeautifulAlertDialog(this.buttons, this.title, this.message);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(right: 16.0),
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(75),
              bottomLeft: Radius.circular(75),
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10)
            )
          ),
          child: Row(
            children: <Widget>[
              SizedBox(width: 20.0),
              CircleAvatar(radius: 40, backgroundColor: Colors.grey.shade500,
                //child: Image.asset('assets/img/info-icon.png', width: 60,)
                ),
              SizedBox(width: 20.0),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: Theme.of(context).textTheme.title,),
                    SizedBox(height: 10.0),
                    Flexible(
                      child: Text(
                        message),
                    ),
                    SizedBox(height: 10.0),

                    (buttons == true) ? Row(children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          child: Text("No"),
                          color: Colors.red,
                          colorBrightness: Brightness.dark,
                          onPressed: (){Navigator.pop(context);},
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: RaisedButton(
                          child: Text("Yes"),
                          color: Colors.green,
                          colorBrightness: Brightness.dark,
                          onPressed: (){Navigator.pop(context);},
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                        ),
                      ),
                    ]) : Container(width: 0,height: 0),


                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}