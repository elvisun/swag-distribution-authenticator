import tensorflow as tf

interpreter = tf.contrib.lite.Interpreter(model_path="model.tflite")
interpreter.allocate_tensors()

def printModelDimension():
	# Print input shape and type
	print(interpreter.get_input_details()[0]['shape'])  # Example: [1 224 224 3]
	print(interpreter.get_input_details()[0]['dtype'])  # Example: <class 'numpy.float32'>

	# Print output shape and type
	print(interpreter.get_output_details()[0]['shape'])  # Example: [1 1000]
	print(interpreter.get_output_details()[0]['dtype'])  # Example: <class 'numpy.float32'>

def main():
	printModelDimension()	

if __name__ == '__main__':
  main()
  