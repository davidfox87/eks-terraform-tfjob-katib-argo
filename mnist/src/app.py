import numpy as np
import tensorflow as tf
import tensorflow_datasets as tfds
from tensorflow import keras
from tensorflow.keras import layers
from datetime import datetime

tfds.disable_progress_bar()

import argparse
import logging
import sys


#Use this format (%Y-%m-%dT%H:%M:%SZ) to record timestamp of the metrics
logging.basicConfig(
    format="%(asctime)s %(levelname)-8s %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%SZ",
    level=logging.DEBUG)


def parse_arguments(argv):

  parser = argparse.ArgumentParser()
  parser.add_argument('--log_dir', 
                      type=str, 
                      default='/logs',
                      help='Name of the model folder.')
  parser.add_argument('--train_steps',
                      type=int,
                      default=2,
                      help='The number of training steps to perform.')
  parser.add_argument('--batch_size',
                      type=int,
                      default=10,
                      help='The number of batch size during training')
  parser.add_argument('--learning_rate',
                      type=float,
                      default=0.01,
                      help='Learning rate for training.')
  parser.add_argument('--export_folder',
                      type=float,
                      help='folder to save model')

  args, _ = parser.parse_known_args(args=argv[1:])

  return args

# Katib parses metrics in this format: <metric-name>=<metric-value>.
class StdOutCallback(tf.keras.callbacks.Callback):
    def on_epoch_end(self, epoch, logs=None):
        logging.info(
            "Epoch {:4d}/{}. accuracy={:.4f} - loss={:.4f}".format(
                epoch+1, logs["accuracy"], logs["loss"]
            )
        )
  

def build_and_compile_cnn_model(dropout, lr):
  # Model / data parameters
  num_classes = 10
  input_shape = (28, 28, 1)

  model = keras.Sequential(
      [
          keras.Input(shape=input_shape),
          layers.Conv2D(32, kernel_size=(3, 3), activation="relu"),
          layers.MaxPooling2D(pool_size=(2, 2)),
          layers.Conv2D(64, kernel_size=(3, 3), activation="relu"),
          layers.MaxPooling2D(pool_size=(2, 2)),
          layers.Flatten(),
          layers.Dropout(dropout),
          layers.Dense(num_classes, activation="softmax"),
      ]
  )

  #opt = keras.optimizers.Adam(learning_rate=lr)
  model.compile(
      loss=tf.keras.losses.sparse_categorical_crossentropy,
      optimizer=tf.keras.optimizers.SGD(learning_rate=lr),
      metrics=['accuracy']
  )

  
  return model



def make_dataset():
  # Load the data and split it between train and test sets
  (x_train, y_train), (x_test, y_test) = keras.datasets.mnist.load_data()

  # Scale images to the [0, 1] range
  x_train = x_train.astype("float32") / 255.
  x_test = x_test.astype("float32") / 255.
  # Make sure images have shape (28, 28, 1)
  x_train = np.expand_dims(x_train, -1)
  x_test = np.expand_dims(x_test, -1)

  return x_train, y_train, x_test, y_test


def main(argv=None):
  args = parse_arguments(sys.argv if argv is None else argv)

  x_train, y_train, x_test, y_test = make_dataset()

  model = build_and_compile_cnn_model(dropout=0.5, lr=args.learning_rate)

  logdir = "/logs" + datetime.now().strftime("%Y%m%d-%H%M%S")
  tensorboard_callback= tf.keras.callbacks.TensorBoard(log_dir=logdir,
                                                       update_freq='epoch',
                                                    )
    
  std_out = StdOutCallback()
  model.fit(x=x_train, 
          y=y_train, 
          epochs=5,
          batch_size=args.batch_size, 
          validation_data=(x_test, y_test), 
          callbacks=[tensorboard_callback, std_out])


  if args.export_folder:
    model.save(args.export_folder)


def eval_model(model, test_X, test_y):
  # evaluate the model performance
  score = model.evaluate(test_X, test_y, verbose=0)
  # if we can use the tf.event to collect metrics then we can display the 
  # train and validation curves for each trial
  print("accuracy={:2f}".format(score[1]))


if __name__ == '__main__':
  logging.basicConfig(level=logging.INFO)
  main()
