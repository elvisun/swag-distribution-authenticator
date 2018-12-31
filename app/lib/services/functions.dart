import 'package:cloud_functions/cloud_functions.dart';
import 'dart:math';

Future<String> getMaxSimilarity(List<int> array) async {
  if (array.length != 128) {
    throw ArgumentError('vector dimension needs to be 128');
  }

  var res = await CloudFunctions.instance
      .call(functionName: 'calculateFaceSimilarity', parameters: {
    'vector': List.of(array),
  });
  print(res);
  double similarity = res['similarity'];
  return similarity.toString();
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
