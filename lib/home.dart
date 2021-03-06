import 'package:flutter/material.dart';
import 'login.dart';
import 'style.dart';
import 'supporter_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_id/device_id.dart';
import 'const.dart';

class HomePage extends StatefulWidget {

  static String tag = 'home-page';

  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {


  String _deviceid = 'Unknown';
  SharedPreferences prefs;
  bool isLoading = false;

  Future<Null> handleSignIn(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
    });
    _deviceid = await DeviceId.getID;

    if (_deviceid != null) {
      // Check is already sign up
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: _deviceid)
          .getDocuments();

      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        // Update data to server if new user
        Firestore.instance
            .collection('users')
            .document(_deviceid)
            .setData({'name': _deviceid, 'id': _deviceid,'type':'2','photoUrl':''});

        await prefs.setString('id', _deviceid);
        await prefs.setString('name', _deviceid);
        await prefs.setString('type','2');
        await prefs.setString('photoUrl', '');
      } else {
        // Write data to local
        await prefs.setString('id', documents[0]['id']);
        await prefs.setString('name', documents[0]['name']);
        await prefs.setString('type', documents[0]['type']);
        await prefs.setString('photoUrl', documents[0]['photoUrl']);
      }
      Fluttertoast.showToast(msg: "Sign in success");

      this.setState(() {
        isLoading = false;
      });

      Navigator.of(context).pushNamed(ListPage.tag);
    } else {
      Fluttertoast.showToast(msg: "Sign in fail");
      this.setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.all(30.0),
        child: CircleAvatar(
          radius: 80.0,
          backgroundColor: Colors.transparent,
          backgroundImage: AssetImage('assets/bg_info.png'),
        ),
      ),
    );

    final welcome = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        'Welcome from Mee Pya Tike',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 21.0, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );

    final lorem = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        ' Mee Pya Tike will take you to brighter future!!',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16.0, color: Colors.white),
      ),
    );

    final anonymousRaiseButton = new SizedBox(
      height: 42.0,
      width: 200.0,
      child: RaisedButton(
        onPressed: () {
          handleSignIn(context);
        },
        child: Text('Anonymous Login'),
        elevation: 8.0,
        textColor: Colors.lightBlue,
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(5.0)),
        color: Colors.white,
        splashColor: Colors.lightBlueAccent,
      ),
    );

    final supporterRaiseButton = new SizedBox(
      height: 42.0,
      width: 200.0,
      child: RaisedButton(
        child: Text('Supporter Login'),
        elevation: 8.0,
        textColor: Colors.white,
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(5.0)),
        color: Colors.lightBlue,
        splashColor: Colors.lightBlueAccent,
        onPressed: () {
          Navigator.of(context).pushNamed(LoginPage.tag);
        },
      ),
    );

    final loading = Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                ),
              ),
              color: Colors.transparent,
            )
          : Container(),
    );

    final body = Stack(children: <Widget>[
      Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(28.0),
        decoration: new BoxDecoration(
          image: backgroundImage,
        ),
        /*decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.blue,
          Colors.lightBlueAccent,
        ]),
      ),*/
        child: Column(
          children: <Widget>[
            logo,
            welcome,
            lorem,
            SizedBox(height: 30.0),
            anonymousRaiseButton,
            SizedBox(height: 14.0),
            supporterRaiseButton
          ],
        ),
      ),
      loading
    ]);

    return Scaffold(
      body: body,
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
  }
}
