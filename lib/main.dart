import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:validator_app/api.dart';
import 'package:validator_app/data.dart';
import 'package:validator_app/settings.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Eventsurfer Validator',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: CupertinoButton.filled(
          child: Text("Scan Barcode"),
          onPressed: () async {
            try {
              List<String> ids = (await BarcodeScanner.scan()).split("\n");

              Ticket t = await validateTicket(await getUser(), ids[3], int.parse(ids[2]));
              Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) => TicketInfoPage(t)));
            } catch (e) {
              if (e is ValidationException) {
                showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) => CupertinoAlertDialog(
                        title: Text("Error ${e.code}"),
                        content: Text(e.message),
                        actions: [
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            child: Text(
                              "Close",
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop("Cancel");
                            },
                          )
                        ],
                      ),
                );
              } else {
                print(e.toString());
              }
            }
          },
        ),
      ),
      navigationBar: CupertinoNavigationBar(
        trailing: CupertinoButton(
          padding: EdgeInsets.all(0),
          child: Icon(CupertinoIcons.settings),
          onPressed: () {
            Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) => Settings()));
          },
        ),
      ),
    );
  }
}

class TicketInfoPage extends StatelessWidget {
  final Ticket _ticket;

  const TicketInfoPage(this._ticket, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: ListView(
          children: <Widget>[
            Text(this._ticket.valid ? "Ticket valid" : "Ticket invalid"),
            Text("Gekauft am: ${DateFormat.yMd(Intl.systemLocale).add_Hm().format(this._ticket.createdAt)}"),
            this._ticket.valid
                ? Icon(
                    CupertinoIcons.check_mark_circled_solid,
                    color: Colors.green,
                  )
                : Icon(
                    CupertinoIcons.clear_thick,
                    color: Colors.red,
                  )
          ],
        ),
      ),
      navigationBar: CupertinoNavigationBar(),
    );
  }
}

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController _apiController = TextEditingController();
  TextEditingController _userController = TextEditingController();
  TextEditingController _pswController = TextEditingController();

  _SettingsState() {
    getApiKey().then((String key) {
      setState(() {
        _apiController.text = key;
      });
    });
    getUser().then((User user) {
      setState(() {
        _userController.text = user.email;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
        child: ListView(
          children: <Widget>[
            CupertinoTextField(
              controller: this._apiController,
              clearButtonMode: OverlayVisibilityMode.editing,
              placeholder: "API Key",
              autocorrect: false,
              maxLines: 1,
              suffix: CupertinoButton(
                child: Icon(CupertinoIcons.photo_camera),
                onPressed: () {
                  setState(() async {
                    this._apiController.text = await BarcodeScanner.scan();
                  });
                },
              ),
            ),
            CupertinoTextField(
              controller: _userController,
              clearButtonMode: OverlayVisibilityMode.editing,
              placeholder: "Username",
              autocorrect: false,
              maxLines: 1,
            ),
            CupertinoTextField(
              controller: _pswController,
              clearButtonMode: OverlayVisibilityMode.editing,
              placeholder: "Password",
              obscureText: true,
              maxLines: 1,
            ),
            CupertinoButton.filled(
              child: Text("Login"),
              onPressed: () async {
                saveApiKey(this._apiController.text);
                saveUser(await signUserIn(this._userController.text, this._pswController.text));
                Navigator.pop(context);
                // TODO user feedback
              },
            )
          ],
        ),
      ),
      navigationBar: CupertinoNavigationBar(),
    );
  }
}
