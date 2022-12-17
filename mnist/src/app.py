"""
Title: Simple MNIST convnet
Author: [fchollet](https://twitter.com/fchollet)
Date created: 2015/06/19
Last modified: 2020/04/21
Description: A simple convnet that achieves ~99% test accuracy on MNIST.
"""

"""
## Setup
"""

import numpy as np
from tensorflow import keras
from tensorflow.keras import layers
import argparse
import sys
import logging

def parse_arguments(argv):

  parser = argparse.ArgumentParser()
  parser.add_argument('--model_folder', 
                      type=str, 
                      required=True, 
                      help='Name of the model folder.')
  parser.add_argument('--train_steps',
                      type=int,
                      default=200,
                      help='The number of training steps to perform.')
  parser.add_argument('--batch_size',
                      type=int,
                      default=100,
                      help='The number of batch size during training')
  parser.add_argument('--learning_rate',
                      type=float,
                      default=0.01,
                      help='Learning rate for training.')

  args, _ = parser.parse_known_args(args=argv[1:])

  return args




def main(argv=None):
  args = parse_arguments(sys.argv if argv is None else argv)

  """
  ## Prepare the data
  """
  # Model / data parameters
  num_classes = 10
  input_shape = (28, 28, 1)

  # Load the data and split it between train and test sets
  (x_train, y_train), (x_test, y_test) = keras.datasets.mnist.load_data()

  # Scale images to the [0, 1] range
  x_train = x_train.astype("float32") / 255
  x_test = x_test.astype("float32") / 255
  # Make sure images have shape (28, 28, 1)
  x_train = np.expand_dims(x_train, -1)
  x_test = np.expand_dims(x_test, -1)
  print("x_train shape:", x_train.shape)
  print(x_train.shape[0], "train samples")
  print(x_test.shape[0], "test samples")


  # convert class vectors to binary class matrices
  y_train = keras.utils.to_categorical(y_train, num_classes)
  y_test = keras.utils.to_categorical(y_test, num_classes)

  """
  ## Build the model
  """

  model = keras.Sequential(
      [
          keras.Input(shape=input_shape),
          layers.Conv2D(32, kernel_size=(3, 3), activation="relu"),
          layers.MaxPooling2D(pool_size=(2, 2)),
          layers.Conv2D(64, kernel_size=(3, 3), activation="relu"),
          layers.MaxPooling2D(pool_size=(2, 2)),
          layers.Flatten(),
          layers.Dropout(0.5),
          layers.Dense(num_classes, activation="softmax"),
      ]
  )

  model.summary()

  """
  ## Train the model
  """

  opt = keras.optimizers.Adam(learning_rate=args.learning_rate)
  model.compile(loss="categorical_crossentropy", 
                optimizer=opt, metrics=["accuracy"])

  model.fit(x_train, y_train, 
            batch_size=args.batch_size, 
            epochs=args.train_steps, validation_split=0.1)

  """
  ## Evaluate the trained model
  """

  score = model.evaluate(x_test, y_test, verbose=0)
  print("Test loss:", score[0])
  print("Test accuracy:", score[1])

  model.save(args.model_folder)

if __name__ == '__main__':
  logging.basicConfig(level=logging.INFO)
  main()