import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:validator_app/data.dart';
import 'package:validator_app/settings.dart';

const String host = "http://eventsurfer.online/";

Future<Ticket> validateTicket(User user, String validateId, int ticketId) async {
  final http.Response response = await http.post(
      "${host}api/v1/tickets/validate_ticket?user_id=${user.id}&validate_id=${Uri.encodeQueryComponent(validateId)}&ticket_id=$ticketId",
      headers: {"X-EVENTSURFER-Auth": await getApiKey()});
  if (response.statusCode == 200) {
    return Ticket.fromJson(json.decode(response.body)["ticket"]);
  } else {
    throw TicketValidationException(json.decode(response.body)["error"], response.statusCode, validateId, ticketId);
  }
}

Future<User> signUserIn(String email, String password) async {
  final http.Response response = await http.post(
      "${host}api/v1/users/signIn?user_email=${Uri.encodeQueryComponent(email)}&passwd=${Uri.encodeQueryComponent(password)}",
      headers: {"X-EVENTSURFER-Auth": await getApiKey()});
  if (response.statusCode == 200) {
    return User.fromJson(json.decode(response.body)["user"]);
  } else {
    throw UserValidationException(json.decode(response.body)["error"], response.statusCode, email);
  }
}
