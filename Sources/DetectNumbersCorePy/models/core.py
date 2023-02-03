import matplotlib.pyplot as plt
import numpy as np
from models.dense import TrainingDense, sigmoid, sigmoid_derive, softmax
from utils.parse_csv import parse_csv


def train(lr, first_layer_size: int = 256, show_plot: bool = True):
    train_inputs, train_targets = parse_csv("mnist_train")
    test_inputs, test_targets = parse_csv("mnist_test")

    layers = [TrainingDense(train_inputs.shape[0], first_layer_size, sigmoid, sigmoid_derive, lr),
              TrainingDense(first_layer_size, train_targets.shape[0], softmax, None, lr)]

    epoch_errors = []
    for i in range(450):
        result = train_inputs
        for layer in layers:
            result = layer.forward(result)

        loss = __logloss(train_targets, result)
        epoch_errors.append(loss)

        dE = __logloss_derive(train_targets, result)
        for layer in list(reversed(layers)):
            dE = layer.backward(dE)

    __save_weights([d.weights for d in layers])

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

# Training error handling


def __logloss(target, result):
    return (-1 / target.shape[1]) * np.sum(target * np.log(result + 1e-5))


def __logloss_derive(target, result):
    return result - target


# Utils


def __save_weights(weights):
    text_file = open(
        "Sources/DetectNumbersCore/Generated/BestWeights.swift", "w")
    text_file.write("let bestWeights: [[[Double]]] = [")
    for dense in weights:
        text_file.write("\n    ")
        text_file.write(__array_to_string(dense))
        text_file.write(",")
    text_file.write("\n]")
    text_file.close()

    text_file = open(
        "Sources/DetectNumbersCorePy/generated/best_weights.py", "w")
    text_file.write("bestWeights = [")
    for dense in weights:
        text_file.write("\n    ")
        text_file.write(__array_to_string(dense))
        text_file.write(",")
    text_file.write("\n]")
    text_file.close()


def __array_to_string(arrays):
    return '[' + ','.join('[' + ','.join([str(value) for value in row]) + ']' for row in arrays) + ']'
