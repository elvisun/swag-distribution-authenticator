import * as functions from 'firebase-functions';
import * as firestore from 'firestore';

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
export const helloWorld = functions.https.onCall((data, context) => {
	// if(data.vector.length != 128) {
	// 	throw new functions.https.HttpsError('invalid-argument', 'vector must have length of 128');
	// }
	console.log('hello world');
	// firestore.doc('/face_vectors').getCollections.then(collections => {
	// 	console.log(collections);
	// });
	return data;
});

