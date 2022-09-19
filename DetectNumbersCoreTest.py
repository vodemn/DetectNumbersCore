from array import array
from cgitb import text
import csv
import string
from tokenize import Double
import matplotlib.pyplot as plt
import numpy as np
import scipy.io


def run_lab(lr, first_layer_size: int = 256, show_plot: bool = True):
    train_inputs, train_targets = parse_csv("mnist_train")
    test_inputs, test_targets = parse_csv("mnist_test")

    layers = [Dense(train_inputs.shape[0], first_layer_size, sigmoid, sigmoid_derive, lr),
              Dense(first_layer_size, train_targets.shape[0], softmax, None, lr)]

    epoch_errors = []
    for i in range(500):
        result = train_inputs
        for layer in layers:
            result = layer.forward(result)

        loss = logloss(train_targets, result)
        epoch_errors.append(loss)

        dE = logloss_derive(train_targets, result)
        for layer in list(reversed(layers)):
            dE = layer.backward(dE)

    saveWeights([d.weights for d in layers])

    if (show_plot):
        plt.plot(epoch_errors)
        plt.show()

    result = test_inputs
    for layer in layers:
        result = layer.forward(result)

    digits = np.argmax(test_targets, axis=0)
    predicted_digits = np.argmax(result, axis=0)
    prediction_accuracy = np.sum(
        digits == predicted_digits) / test_inputs.shape[1]

    return prediction_accuracy


def parse_csv(filename: string):
    inputs = []
    targets = []
    with open('Sources/Dataset/' + filename + '.csv', newline='') as csvfile:
        rows = csv.reader(csvfile, delimiter='\n')
        for i, row in enumerate(rows):
            if (i > 0):
                values = row[0].split(",")
                inputs.append(
                    [int(value) / 255 for value in values[1:]])
                targets.append(int_to_onehot(int(values[0])))
    inputs = np.array(inputs).T
    targets = np.array(targets).T
    return (inputs, targets)


def int_to_onehot(n: int) -> np.array:
    v = [0] * 10
    v[n] = 1
    return np.array(v)


class Dense:
    def __init__(self, in_dim, neurons_count, h, h_derive, lr):
        np.random.seed(0)
        self.weights = 2 * \
            np.random.random((neurons_count, in_dim + 1)) / \
            np.sqrt(neurons_count + in_dim + 1)
        self.cache = None
        self.activation = h
        self.activation_derive = h_derive
        self.learning_rate = lr

    def forward(self, x):
        x_ext = np.vstack([x, np.ones((1, x.shape[1]))])
        output = self.activation(self.weights @ x_ext)
        self.cache = (x_ext, output)
        return output

    def backward(self, dE):
        input = self.cache[0]
        output = self.cache[1]
        deriv_act = dE
        if self.activation_derive is not None:
            deriv_act *= self.activation_derive(output)
        deriv_act = (deriv_act / 1000) @ input.T
        dE_next = (dE.T @ self.weights).T
        dE_next = dE_next[:dE_next.shape[0] - 1]
        self.weights -= deriv_act * self.learning_rate
        return dE_next


def logloss(target, result):
    return (-1 / target.shape[1]) * np.sum(target * np.log(result + 1e-5))


def logloss_derive(target, result):
    return result - target


def sigmoid(i):
    return 1/(1 + np.exp(-i))


def sigmoid_derive(i):
    return i * (1 - i)


def softmax(i):
    e = np.exp(i - np.max(i, axis=0, keepdims=True))
    e_sum = np.sum(e, axis=0, keepdims=True)
    return e / e_sum

def saveWeights(weights):
    text_file = open("Sources/DetectNumbersCore/Generated/BestWeights.swift", "w")
    text_file.write("let bestWeights: [[[Double]]] = [")
    for dense in weights:
        text_file.write("\n    ")
        text_file.write(arraysToString(dense))
        text_file.write(",")
    text_file.write("\n]")
    text_file.close()


def arraysToString(arrays):
    return '[' + ','.join('[' + ','.join([str(value) for value in row]) + ']' for row in arrays) + ']'


result = run_lab(lr=0.08, first_layer_size=28, show_plot=False)
print(result)


