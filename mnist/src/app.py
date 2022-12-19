import numpy as np
import tensorflow as tf
import tensorflow_datasets as tfds
from tensorflow import keras
from tensorflow.keras import layers

tfds.disable_progress_bar()

import argparse
import logging
import sys


# Use this format (%Y-%m-%dT%H:%M:%SZ) to record timestamp of the metrics
logging.basicConfig(
    format="%(asctime)s %(levelname)-8s %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%SZ",
    level=logging.DEBUG)


def parse_arguments(argv):

  parser = argparse.ArgumentParser()
  parser.add_argument('--log_dir', 
                      type=str, 
                      default='/tensorboard',
                      help='Name of the model folder.')
  parser.add_argument('--train_steps',
                      type=int,
                      default=10,
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

class StdOutCallback(tf.keras.callbacks.ProgbarLogger):
    # a simple callback that picky-backs of the progress bar callback. It prints metrics to StdOut.
    def on_batch_end(self, batch, logs=None):
        logs = logs or {}
        for k in self.params['metrics']:
            if k in logs:
                print("{}={}".format(k,logs[k]))

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


def make_datasets_unbatched(dataset_name):
  # Scaling MNIST data from (0, 255] to (0., 1.]
  def scale(image, label):
    image = tf.cast(image, tf.float32)
    image /= 255
    return image, label

  (ds_train, ds_test), ds_info = tfds.load(dataset_name,
                                        split=['train', 'test'],
                                        shuffle_files=True,
                                        as_supervised=True,
                                        with_info=True,
                                      )
  ds_train = ds_train.map(
    scale, num_parallel_calls=tf.data.AUTOTUNE)
  ds_train = ds_train.cache()
  ds_train = ds_train.shuffle(ds_info.splits['train'].num_examples)
  ds_train = ds_train.batch(128)
  ds_train = ds_train.prefetch(tf.data.AUTOTUNE)

  ds_test = ds_test.map(
    scale, num_parallel_calls=tf.data.AUTOTUNE)
  ds_test = ds_test.batch(128)
  ds_test = ds_test.cache()
  ds_test = ds_test.prefetch(tf.data.AUTOTUNE)

  return ds_train, ds_test

def main(argv=None):
  args = parse_arguments(sys.argv if argv is None else argv)

  ds_train, ds_test = make_datasets_unbatched('mnist')

  model = build_and_compile_cnn_model(dropout=0.5, lr=args.learning_rate)

  tensorboard = tf.keras.callbacks.TensorBoard(log_dir=args.log_dir, 
                                               update_freq="batch")      
  std_out = StdOutCallback()

  model.fit(
    ds_train,
    epochs=args.train_steps,
    validation_data=ds_test,
    callbacks=[tensorboard, std_out]
  )

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
