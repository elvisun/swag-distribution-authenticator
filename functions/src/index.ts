import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as math from 'mathjs';

admin.initializeApp();



export const helloWorld = functions.https.onCall((data, context) => {
	if (data.vector == null || data.vector.length != 128) {
		throw new Error('Input vector must be of length 128');
	}
	//TODO: handle empty case here
	return admin.firestore().collection('face_vectors').select('vector').get().then(function(res) {
			var smallestCosDistance = res.docs.map((doc) => doc.get('vector'))
					.map((vector) => math.dot(vector, data.vector))
					.reduce((a, b) => math.min(a, b));
			return {
				result: "hello",
				distance: smallestCosDistance
			};
		}
	);
});

// Array of dimension 128
// var testArray = [
// 127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
// 127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
// 127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
// 127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
// 127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
// 127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
// 127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
// 127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
// 127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
// 127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
// 127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
// 127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
// 127,  125,  122,  135,  114,  122,  131,  130];
