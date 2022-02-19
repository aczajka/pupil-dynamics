'''
An illustration of how to use Recurrent Neural Networks in pupil-dynamics-based presentation attack detection.

This code is based on the TensorFlow example written by Aymeric Damien, https://github.com/aymericdamien/TensorFlow-Examples/

Modifications (basics RNN cell, variants of LSTM) done by Toan Nguyen, Benedict Becker, Adam Czajka (2016-2017)
'''

from __future__ import print_function, division

import tensorflow as tf
from tensorflow.contrib import rnn as rnn_cell
import numpy as np
import sys

# Network parameters
learning_rate = 0.0001
training_iters = 200000
display_step = 100
n_hidden = 24  # number of neurons in a hidden layer
n_classes = 2  # pupil dynamics total classes (live or spoof)

# Define the network input
n_input = 25 # size of the input vector
n_steps = 5  # timesteps
batch_size = 16  # batchsize

def evaluate_model(test, func, type):
    # tf Graph input
    x = tf.placeholder("float", [None, n_steps, n_input])
    y = tf.placeholder("float", [None, n_classes])

    # Define weights, initialize with xavier
    weights = {
        'out': tf.get_variable("W", shape=[n_hidden, n_classes], initializer=tf.contrib.layers.xavier_initializer()),
    }
    biases = {
        'out': tf.get_variable("B", shape=[n_classes], initializer=tf.contrib.layers.xavier_initializer()),
    }

    tf.add_to_collection('vars', weights['out'])
    tf.add_to_collection('vars', biases['out'])

    # Define the network
    pred = func(x, weights, biases)

    # Define the cost function
    cost = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(logits=pred, labels=y))

    # Define the optimization method
    optimizer = tf.train.RMSPropOptimizer(learning_rate).minimize(cost)

    # Evaluate the model
    correct_pred = tf.equal(tf.argmax(pred, 1), tf.argmax(y, 1))
    accuracy = tf.reduce_mean(tf.cast(correct_pred, tf.float32))

    # Initializing the variables
    init = tf.global_variables_initializer()

    saver = tf.train.Saver()

    # Restore the saved model and evaluate the testing data on it
    with tf.Session() as sess:

        sess.run(init)
        model_dir = './model/'+type+ '_' + func.__name__
        saver.restore(sess, model_dir + '/model')

        test_data, test_labels = preprocess(test, n_steps, n_input)
        acc = sess.run(accuracy, feed_dict={x: test_data, y: test_labels})

        return acc

def evaluate(test, func, gen):
    # tf Graph input
    x = tf.placeholder("float", [None, n_steps, n_input])
    y = tf.placeholder("float", [None, n_classes])

    # Define weights, initialize with xavier
    weights = {
        'out': tf.get_variable("W", shape=[n_hidden, n_classes], initializer=tf.contrib.layers.xavier_initializer()),
    }
    biases = {
        'out': tf.get_variable("B", shape=[n_classes], initializer=tf.contrib.layers.xavier_initializer()),
    }

    # Define the network
    pred = func(x, weights, biases)

    # Define the cost function
    cost = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(logits=pred, labels=y))

    # Define the optimization method
    optimizer = tf.train.RMSPropOptimizer(learning_rate).minimize(cost)

    # Evaluate the model
    correct_pred = tf.equal(tf.argmax(pred, 1), tf.argmax(y, 1))
    accuracy = tf.reduce_mean(tf.cast(correct_pred, tf.float32))

    # Initializing the variables
    init = tf.global_variables_initializer()

    # Launch the graph
    with tf.Session() as sess:
        sess.run(init)
        step = 1

        # Keep training until reach max iterations
        training_times = []
        while step * batch_size < training_iters:
                
            batch_x, batch_y = next(gen)
                
            # Reshape data
            batch_x = batch_x.reshape((batch_size, n_steps, n_input))
               
            # Run optimization op (backprop)
            sess.run(optimizer, feed_dict={x: batch_x, y: batch_y})
               
            if step % display_step == 0:
                # Calculate batch accuracy
                acc = sess.run(accuracy, feed_dict={x: batch_x, y: batch_y})
                loss = sess.run(cost, feed_dict={x: batch_x, y: batch_y})
                print("Iter " + str(step * batch_size) + ", Minibatch Loss= " + \
                  "{:.6f}".format(loss) + ", Training Accuracy= " + \
                  "{:.5f}".format(acc))
            step += 1

        # preprocess is a function that turns the test data into data and labels, and also reshapes
        # the data into the shape (-1, n_steps, n_input)
        test_data, test_labels = preprocess(test, n_steps, n_input)

        acc = sess.run(accuracy, feed_dict={x: test_data, y: test_labels})

        return acc

def RNN(x, weights, biases):
    # Prepare data shape to match `rnn` function requirements
    # Current data input shape: (batch_size, n_steps, n_input)
    # Required shape: 'n_steps' tensors list of shape (batch_size, n_input)

    # Permuting batch_size and n_steps
    x = tf.transpose(x, [1, 0, 2])
    # Reshaping to (n_steps*batch_size, n_input)
    x = tf.reshape(x, [-1, n_input])
    # Split to get a list of 'n_steps' tensors of shape (batch_size, n_input)
    x = tf.split(x, n_steps, 0)

    # Define the cell

    # Just RNN
    cell = rnn_cell.BasicRNNCell(n_hidden)

    # Get cell output
    outputs, states = rnn_cell.static_rnn(cell, x, dtype=tf.float32)

    # Linear activation, using RNN inner loop last output
    return tf.matmul(outputs[-1], weights['out']) + biases['out']

def classic_LSTM(x, weights, biases):
    x = tf.transpose(x, [1, 0, 2])
    x = tf.reshape(x, [-1, n_input])
    x = tf.split(x, n_steps, 0)

    # Just LSTM (with NO peepholes)
    cell = rnn_cell.BasicLSTMCell(n_hidden, forget_bias=1.0)

    outputs, states = rnn_cell.static_rnn(cell, x, dtype=tf.float32)
    return tf.matmul(outputs[-1], weights['out']) + biases['out']

def peephole_LSTM(x, weights, biases):
    x = tf.transpose(x, [1, 0, 2])
    x = tf.reshape(x, [-1, n_input])
    x = tf.split(x, n_steps, 0)

    # LSTM with peepholes
    cell = rnn_cell.LSTMCell(n_hidden, use_peepholes=True)

    outputs, states = rnn_cell.static_rnn(cell, x, dtype=tf.float32)
    return tf.matmul(outputs[-1], weights['out']) + biases['out']

def GRU(x, weights, biases):
    x = tf.transpose(x, [1, 0, 2])
    x = tf.reshape(x, [-1, n_input])
    x = tf.split(x, n_steps, 0)

    # GRU
    cell = rnn_cell.GRUCell(n_hidden)

    outputs, states = rnn_cell.static_rnn(cell, x, dtype=tf.float32)
    return tf.matmul(outputs[-1], weights['out']) + biases['out']

def preprocess(data, ntimesteps, ninput):
    y = np.zeros((len(data), 2))
    x = np.zeros((len(data), ntimesteps, ninput))

    for i, item in enumerate(data):
        # Transcribe labels
        y[i][item[1]] = 1

        # Transcribe data
        arrx = np.asarray(item[0][:(ntimesteps * ninput)])
        x[i] = np.reshape(arrx, (ntimesteps, ninput))

    return x, y

def get_data(path):
    return np.load(path)

if __name__ == '__main__':

    if len(sys.argv) < 2:
        print('Usage: python data_driven_model.py [dark|light|both]')
        exit(1)
    elif sys.argv[1] not in ['dark', 'light', 'both']:
        print('Usage: python data_driven_model.py [dark|light|both]')
        exit(1)
    else:
        type = sys.argv[1]

    # Double the number of steps if using both types of data
    if type == 'both':
        n_steps = n_steps*2

    for func in [classic_LSTM, peephole_LSTM, RNN, GRU]:

        ## Load the data
        test = get_data('./demo_data/demo_' + type + 'data.npy')

        # Reset the graph after each function
        tf.reset_default_graph()

        # Batchgen is a generator that iterates through the training data,
        # yielding a data matrix of shape (batch_size, n_steps, n_input)
        
        # batchgen = dat.get_batchgen(train_data, batch_size, n_steps, n_input)

        # To train a new model, use the evaluate function

        # acc = evaluate(test_data, func, batchgen)

        # To use an existing model, use evaluate_model()
        acc = evaluate_model(test, func, type)

        print("Accuracy using {} network: {}\n".format(func.__name__, acc))
