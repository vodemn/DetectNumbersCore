import numpy as np


class DetectingDense:

    def __init__(self, weights, h):
        self.weights = weights
        self.activation = h

    def forward(self, x):
        x_ext = np.vstack([x, np.ones((1, x.shape[1]))])
        output = self.activation(self.weights @ x_ext)
        return output


class TrainingDense:
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


# Layers activation func


def sigmoid(i):
    return 1/(1 + np.exp(-i))


def sigmoid_derive(i):
    return i * (1 - i)


def softmax(i):
    e = np.exp(i - np.max(i, axis=0, keepdims=True))
    e_sum = np.sum(e, axis=0, keepdims=True)
    return e / e_sum
