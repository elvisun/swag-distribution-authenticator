import * as functions from 'firebase-functions';
import * as _ from 'lodash';
// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
export const helloWorld = functions.https.onCall((data, context) => {
	console.log(data);
	return data;
});

