/*
The MIT License (MIT)

Copyright (c) 2015 Tommi Enenkel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

/// The TheGridTest library.
library TheGridTest;


import 'dart:io';
import "dart:async";
import 'package:oauth2/oauth2.dart' as oauth2;


/**
 * This console app will authenticate you with TheGrid and fetch your user
 * profile. No error handling is implemented. The app will print an URL
 * to the console that you need to open in the browser. You then authorize
 * your TheGrid app to use your users credentials to perform API calls.
 * A callback will inform the application about the credentials and the
 * app will perform the actual API call.
**/
main(List<String> arguments) async{
  var env = Platform.environment;

  // !!! Get these by registering an app at https://passport.thegrid.io
  var identifier = env["THEGRID_APP_ID"];
  if (identifier == null) {
    identifier = ""; // put app id here
  }
  var secret = env["THEGRID_APP_SECRET"];
  if (secret == null) {
    secret = ""; // put secret here
  }

  if (identifier.isEmpty || secret.isEmpty) {
    throw("You must register an app, and replace identifier and secret in the code!");
  }

  oauth2.Client client = await connect(identifier, secret);

  // Once you have a Client, you can use it just like any other HTTP
  var result = await client.read("https://passport.thegrid.io/api/user");
  print(result);
  exit(0);
}


oauth2.Client
connect(final String identifier, final String secret) async{

  final authorizationEndpoint =
  Uri.parse("https://passport.thegrid.io/login/authorize/");
  final tokenEndpoint =
  Uri.parse("https://passport.thegrid.io/login/authorize/token");


  final redirectUrl = Uri.parse("http://127.0.0.1:3000/");

  File credentialsFile = new File(".credentials.json");
  bool credentialsExist = await credentialsFile.exists();

  var client = null;
  if (credentialsExist) {
    String json = await credentialsFile.readAsString();
    var credentials = new oauth2.Credentials.fromJson(json);
    client = new oauth2.Client(identifier, secret, credentials);
  }
  else
  {
    // If we don't have OAuth2 credentials yet, we need to get them
    var grant = new oauth2.AuthorizationCodeGrant(
        identifier, secret, authorizationEndpoint, tokenEndpoint);

    String authUrl = grant.getAuthorizationUrl(redirectUrl, scopes:["website_management", "content_management", "update_profile"]);
    print('Open browser and authenticate: ${authUrl}\n');

    HttpServer server = await HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 3000);

    Completer completer = new Completer();

    server.listen((HttpRequest request) {
      request.response.statusCode = HttpStatus.FOUND;
      request.response.close();

      if (completer != null) {
        completer.complete(grant.handleAuthorizationResponse(request.uri.queryParameters));
        completer = null;
      }
    });

    client = await completer.future;

    var file = await credentialsFile.open(mode: FileMode.WRITE);
    await file.writeString(client.credentials.toJson());
    await file.close();
  }

  return client;
}
