import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:validator_app/data.dart';

final FlutterSecureStorage _storage = new FlutterSecureStorage();

saveApiKey(String apiKey) {
  _storage.write(key: "apiKey", value: apiKey);
}

Future<String> getApiKey() async {
  String key = await _storage.read(key: "apiKey");
  return key != null ? key : "";
}

saveUser(User user) {
  _storage.write(key: "user", value: user.toJson().toString());
}

Future<User> getUser() async {
  String jsonUser =  await _storage.read(key: "user");
  return jsonUser != null ? User.fromJson(json.decode(jsonUser)) : User();
}
