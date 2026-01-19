import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../firebase_options.dart';

class FirestoreService {
  final String _projectId = DefaultFirebaseOptions.android.projectId;

  /// Adds a document to the given [collection]. Returns true on success.
  Future<bool> addDocument(String collection, Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = user == null ? null : await user.getIdToken();

    final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/$collection');

    final body = {'fields': _toFirestoreFields(data)};

    final resp = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: json.encode(body));

    return resp.statusCode >= 200 && resp.statusCode < 300;
  }

  /// Sets a document in the given [collection] with the specified [documentId].
  /// Creates or updates the document. Returns true on success.
  Future<bool> setDocument(
      String collection, String documentId, Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = user == null ? null : await user.getIdToken();

    final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/$collection/$documentId');

    final body = {'fields': _toFirestoreFields(data)};

    final resp = await http.patch(url,
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: json.encode(body));

    return resp.statusCode >= 200 && resp.statusCode < 300;
  }

  Map<String, dynamic> _toFirestoreFields(Map<String, dynamic> data) {
    final Map<String, dynamic> fields = {};
    data.forEach((k, v) {
      if (v == null) {
        return;
      }
      if (v is String) {
        fields[k] = {'stringValue': v};
      } else if (v is int) {
        fields[k] = {'integerValue': v.toString()};
      } else if (v is double) {
        fields[k] = {'doubleValue': v};
      } else if (v is bool) {
        fields[k] = {'booleanValue': v};
      } else if (v is DateTime) {
        fields[k] = {'timestampValue': v.toUtc().toIso8601String()};
      } else {
        fields[k] = {'stringValue': v.toString()};
      }
    });
    return fields;
  }

  /// Fetches mood entries for the given [date] (UTC) and current user.
  /// Returns an empty list on failure or when no entries found.
  Future<List<Map<String, dynamic>>> getMoodEntriesForDate(
      DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return [];
    }

    final dateString = date.toUtc().toIso8601String().substring(0, 10);

    final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents:runQuery');

    final query = {
      'structuredQuery': {
        'from': [
          {'collectionId': 'mood_entries'}
        ],
        'where': {
          'compositeFilter': {
            'op': 'AND',
            'filters': [
              {
                'fieldFilter': {
                  'field': {'fieldPath': 'uid'},
                  'op': 'EQUAL',
                  'value': {'stringValue': user.uid}
                }
              },
              {
                'fieldFilter': {
                  'field': {'fieldPath': 'date'},
                  'op': 'EQUAL',
                  'value': {'stringValue': dateString}
                }
              }
            ]
          }
        }
      }
    };

    try {
      final idToken = await user.getIdToken();
      final resp = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            if (idToken != null) 'Authorization': 'Bearer $idToken',
          },
          body: json.encode(query));

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        return [];
      }

      final List<Map<String, dynamic>> results = [];
      final List<dynamic> rows = json.decode(resp.body);
      for (final item in rows) {
        if (item['document'] == null) {
          continue;
        }
        final doc = item['document'];
        final fields = doc['fields'] as Map<String, dynamic>? ?? {};
        final Map<String, dynamic> parsed = {};
        fields.forEach((k, v) {
          if (v.containsKey('stringValue')) {
            parsed[k] = v['stringValue'];
          } else if (v.containsKey('integerValue')) {
            parsed[k] = int.tryParse(v['integerValue']) ?? v['integerValue'];
          } else if (v.containsKey('doubleValue')) {
            parsed[k] = v['doubleValue'];
          } else if (v.containsKey('timestampValue')) {
            parsed[k] = DateTime.parse(v['timestampValue']);
          } else {
            parsed[k] = v.toString();
          }
        });
        results.add(parsed);
      }

      return results;
    } catch (e) {
      return [];
    }
  }
}
