import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as math from 'mathjs';
// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//

admin.initializeApp();

var testArray = [
127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
127,  125,  122,  135,  114,  122,  131,  130,  127,  126,
127,  125,  122,  135,  114,  122,  131,  130];

export const helloWorld = functions.https.onCall((data, context) => {
	// if(data.vector.length != 128) {
	// 	throw new functions.https.HttpsError('invalid-argument', 'vector must have length of 128');
	// }

	console.log('hello world');
	var firestore = admin.firestore();
	var allVectors = [];
	return firestore.collection('face_vectors').select('vector').get().then(function(res) {
			console.log(res.docs[0].get('vector'));
			console.log(math.dot(testArray, res.docs[0].get('vector')));
			return {
				result: "hello"
			};
			// snapshot.forEach(function (doc) {
			// 	console.log(doc.data().vector);
			// 	allVectors.push(doc.data().vector);
			// });
			// console.log("items find:");
			// console.log(allVectors.length);
			// console.log(math.dot(allVectors[0],allVectors[1]));
			// return {result: {
			// 	length: allVectors.length,
			// 	new: "hello",
			// 	dot: math.dot(allVectors[0],allVectors[1])
			// }};
		}
	);
});

