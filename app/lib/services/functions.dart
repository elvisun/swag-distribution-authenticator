import 'package:cloud_functions/cloud_functions.dart';
import 'dart:math';

Future<num> getMaxSimilarity(List<int> array) async {
  if (array.length != 128) {
    throw ArgumentError('vector dimension needs to be 128');
  }

  var res = await CloudFunctions.instance
      .call(functionName: 'calculateFaceSimilarity', parameters: {
    'vector': List.of(array),
  });
  print(res);
  double similarity = res['similarity'];
  return similarity;
}

String similarityToString(num x) {
  if (0.9 <= x && x < 1) {
    return 'Hello again!';
  }
  if (0.8 <= x && x < 0.9) {
    return 'Have I seen you before? I\'m not too sure...';
  }
  if (0 <= x && x < 0.8) {
    return 'Nice meeting you!';
  }
  return 'Nice meeting you!';
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
