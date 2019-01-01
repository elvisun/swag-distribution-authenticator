import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import '../models/calculate_embedding.dart';
import 'dart:math';

/// Find the maximum similarity score among all faces it has seen.
Future<num> getMaxSimilarity(List<int> array,
    {@required DocumentSnapshot session}) async {
  if (array.length != 128) {
    throw ArgumentError('vector dimension needs to be 128');
  }

  print(
      'Comparing with collection: ${session.reference.collection(vectorCollectionName).path}');
  var res = await CloudFunctions.instance
      .call(functionName: 'calculateFaceSimilarity', parameters: {
    'sessionPath': session.reference.collection(vectorCollectionName).path,
    'vector': List.of(array),
  });

  double similarity = res['similarity'];
  return similarity;
}

String similarityToString(num x) {
  const _threshold = 0.94;
  if (_threshold <= x && x < 1) {
    return 'Hello again! (similarity: $x)';
  }
  if (0 <= x && x < _threshold) {
    return 'Nice meeting you! (similarity: $x)';
  }
  return 'Nice meeting you! (similarity: $x)';
}

const testData = [
  127,
  125,
  122,
  135,
  114,
  122,
  131,
  130,
  127,
  126,
  127,
  125,
  122,
  135,
  114,
  122,
  131,
  130,
  127,
  126,
  127,
  125,
  122,
  135,
  114,
  122,
  131,
  130,
  127,
  126,
  127,
  125,
  122,
  135,
  114,
  122,
  131,
  130,
  127,
  126,
  127,
  125,
  122,
  135,
  114,
  122,
  131,
  130,
  127,
  126,
  127,
  125,
  122,
  135,
  114,
  122,
  131,
  130,
  127,
  126,
  127,
  125,
  122,
  135,
  114,
  122,
  131,
  130,
  127,
  126,
  127,
  125,
  122,
  135,
  114,
  122,
  131,
  130,
  127,
  126,
  127,
  125,
  122,
  135,
  114,
  122,
  131,
  130,
  127,
  126,
  127,
  125,
  122,
  135,
  114,
  122,
  131,
  130,
  127,
  126,
  127,
  125,
  122,
  135,
  114,
  122,
  131,
  130,
  127,
  126,
  127,
  125,
  122,
  135,
  114,
  122,
  131,
  130,
  127,
  126,
  127,
  125,
  122,
  135,
  114,
  122,
  131,
  130
];
