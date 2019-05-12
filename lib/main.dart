import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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
          child: Text("Scan QR Code"),
          onPressed: () async {
            try {
              String barcode = await BarcodeScanner.scan();

              List<String> ids = barcode.split("D");

              int ticketID = int.parse(ids.removeLast());
              String validateID = ids.join();

              Ticket t = await validateTicket(await getUser(), barcode, ticketID);
              Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) => TicketInfoPage(t)));
            } catch (e) {
              if (e is TicketValidationException) {
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
                              style: TextStyle(color: CupertinoColors.destructiveRed),
                            ),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop("Cancel");
                            },
                          )
                        ],
                      ),
                );
              } else if (e is PlatformException && e.message.contains("error:1e000065:Cipher")) {
                showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) => CupertinoAlertDialog(
                        title: Text("Kein angemeldeter Benutzer"),
                        actions: [
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            child: Text(
                              "Close",
                              style: TextStyle(color: CupertinoColors.destructiveRed),
                            ),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop("Cancel");
                            },
                          )
                        ],
                      ),
                );
              } else {
                showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) => CupertinoAlertDialog(
                        title: Text("Invalider Barcode"),
                        actions: [
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            child: Text(
                              "Close",
                              style: TextStyle(color: CupertinoColors.destructiveRed),
                            ),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop("Cancel");
                            },
                          )
                        ],
                      ),
                );
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            Center(
              child: Text(this._ticket.valid ? "Ticket valid" : "Ticket invalid"),
            ),
            Center(
              child: Text("Gekauft am: ${DateFormat.yMd(Intl.systemLocale).add_Hm().format(this._ticket.createdAt)}"),
            ),
            this._ticket.valid
                ? Icon(
                    CupertinoIcons.check_mark_circled_solid,
                    color: CupertinoColors.activeGreen,
                  )
                : Icon(
                    CupertinoIcons.clear_thick,
                    color: CupertinoColors.destructiveRed,
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
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: CupertinoTextField(
                controller: this._apiController,
                clearButtonMode: OverlayVisibilityMode.editing,
                placeholder: "API Key",
                autocorrect: false,
                maxLines: null,
                prefix: GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.0),
                    child: Icon(
                      CupertinoIcons.photo_camera_solid,
                      size: 18.0,
                      color: Color(0xFFC2C2C2),
                    ),
                  ),
                  onTap: () {
                    setState(() async {
                      try {
                        this._apiController.text = await BarcodeScanner.scan();
                      } catch (e) {}
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: CupertinoTextField(
                controller: _userController,
                clearButtonMode: OverlayVisibilityMode.editing,
                keyboardType: TextInputType.emailAddress,
                placeholder: "E-Mail",
                autocorrect: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: CupertinoTextField(
                controller: _pswController,
                clearButtonMode: OverlayVisibilityMode.editing,
                placeholder: "Password",
                obscureText: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: CupertinoButton.filled(
                child: Text("Login"),
                onPressed: () async {
                  saveApiKey(this._apiController.text);
                  try {
                    User u = await signUserIn(this._userController.text, this._pswController.text);
                    saveUser(u);
                    Navigator.pop(context);

                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext context) => CupertinoAlertDialog(
                            title: Text("Login erfolgreich"),
                            content: Text("Sie haben sich erfolgreich als ${u.name} angemeldet"),
                            actions: [
                              CupertinoDialogAction(
                                isDefaultAction: true,
                                child: Text(
                                  "Close",
                                ),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true).pop("Cancel");
                                },
                              )
                            ],
                          ),
                    );
                  } catch (e) {
                    if (e is UserValidationException) {
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
                                    style: TextStyle(color: CupertinoColors.destructiveRed),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true).pop("Cancel");
                                  },
                                )
                              ],
                            ),
                      );
                    } else {
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) => CupertinoAlertDialog(
                              title: Text("Error"),
                              content: Text(e.toString()),
                              actions: [
                                CupertinoDialogAction(
                                  isDefaultAction: true,
                                  child: Text(
                                    "Close",
                                    style: TextStyle(color: CupertinoColors.destructiveRed),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true).pop("Cancel");
                                  },
                                )
                              ],
                            ),
                      );
                    }
                  }
                },
              ),
            )
          ],
        ),
      ),
      navigationBar: CupertinoNavigationBar(),
    );
  }
}
