import 'dart:convert';

import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:sizzle_starter/src/feature/auth/logic/token_expirer_helper.dart';

/// {@template fake_http_client}
/// A fake HTTP client, that returns mock responses.
///
/// This is used in the application instead of communicating with a real server.
/// {@endtemplate}
class FakeHttpClient extends MockClient {
  /// {@macro fake_http_client}
  FakeHttpClient() : super(_handler);

  static Future<Response> _handler(Request request) async {
    final helper = TokenExpirerHelper();

    if (request.url.path == '/login') {
      return Response(
        '{"access_token": "abcd", "refresh_token": "abcd"}',
        200,
        request: request,
      );
    }

    if (request.url.path == '/refresh') {
      // if the refresh token is expired, return 401
      if (helper.expireRefresh) {
        return Response(
          'Unauthorized',
          401,
          request: request,
        );
      }

      return Response(
        '{"access_token": "abcd", "refresh_token": "abcd"}',
        200,
        request: request,
      );
    }

    // this is not how things look like in real world, but
    // for the sake of simplicity, we will use this approach
    if (helper.expireAccess || helper.expireRefresh) {
      await Future<void>.delayed(const Duration(seconds: 2));
      return Response(
        'Unauthorized',
        401,
        request: request,
      );
    }

    if (request.url.path == '/pokemons') {
      await Future<void>.delayed(const Duration(seconds: 2));
      return Response(
        json.encode([
          {'name': 'Pikachu', 'type': 'Electric'},
          {'name': 'Charmander', 'type': 'Fire'},
          {'name': 'Squirtle', 'type': 'Water'},
        ]),
        200,
        request: request,
      );
    }

    return Response('Not Found', 404, request: request);
  }
}
