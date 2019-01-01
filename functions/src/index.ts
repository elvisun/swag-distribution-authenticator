import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as math from 'mathjs';
import * as _ from 'lodash';

admin.initializeApp();

function calculateMagnitude(array: number[]) {
	let sum = 0;
	array.forEach((item, index) => {
		sum += (item * item);
	});
	return math.sqrt(sum);
}

function scaleUpSimilarity(similarity) {
	return math.max(0, similarity - 0.99) * 100;
}

export const calculateFaceSimilarity = functions.https.onCall((data, context) => {
	if (data.vector === null || data.vector.length !== 128) {
		throw new Error('Input vector must be of length 128');
	}

	if (data.sessionPath === null) {
		throw new Error('sessionPath cannot be null');
	}

	//TODO: handle empty case here
	return admin.firestore().collection(data.sessionPath).select('vector').get().then(function(res) {
			if (res.docs === null || res.docs.length === 0) {
				return {
					similarity: 0.001  // Never seen this so similar to nothing
				}
			}
			const currentVectorMagnitude = calculateMagnitude(data.vector);
			const largestSimilarity = res.docs.map((doc) => doc.get('vector'))
					.filter(vector => !_.isEqual(data.vector, vector))
					.map((vector) => (math.dot(vector, data.vector))/(currentVectorMagnitude * calculateMagnitude(vector)))
					.map(scaleUpSimilarity)
					.reduce((a, b) => math.max(a, b), 0.001);
			return {
				similarity: largestSimilarity
			};
		}
	);
});

export const calculateAllFaceSimilarity = functions.https.onCall((data, context) => {
	if (data.vector === null || data.vector.length !== 128) {
		throw new Error('Input vector must be of length 128');
	}

	if (data.sessionPath === null) {
		throw new Error('sessionPath cannot be null');
	}

	return admin.firestore().collection(data.sessionPath).select('vector').get().then(function(res) {
			if (res.docs === null || res.docs.length === 0) {
				return {
					similarity: []
				}
			}
			const currentVectorMagnitude = calculateMagnitude(data.vector);
			const similarities = res.docs.map((doc) => doc.get('vector'))
					.filter(vector => !_.isEqual(data.vector, vector))
					.map((vector) => (math.dot(vector, data.vector))/(currentVectorMagnitude * calculateMagnitude(vector)))
					.map(scaleUpSimilarity);
			return {
				similarity: similarities
			};
		}
	);
});

// Test functions
//calculateFaceSimilarity({"sessionPath":"events/-LV5d-j1qa7A7SzSHX42/face_vectors", "vector": [127,  125,  122,  135,  114,  122,  131,  130,  127,  126,127,  125,  122,  135,  114,  122,  131,  130,  127,  126,127,  125,  122,  135,  114,  122,  131,  130,  127,  126,127,  125,  122,  135,  114,  122,  131,  130,  127,  126,127,  125,  122,  135,  114,  122,  131,  130,  127,  126,127,  125,  122,  135,  114,  122,  131,  130,  127,  126,127,  125,  122,  135,  114,  122,  131,  130,  127,  126,127,  125,  122,  135,  114,  122,  131,  130,  127,  126,127,  125,  122,  135,  114,  122,  131,  130,  127,  126,127,  125,  122,  135,  114,  122,  131,  130,  127,  126,127,  125,  122,  135,  114,  122,  131,  130,  127,  126,127,  125,  122,  135,  114,  122,  131,  130,  127,  126,127,  125,  122,  135,  114,  122,  131,  130]});
