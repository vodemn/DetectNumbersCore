# DetectNumbersCore

## About

This package implements a neural network trained on MNIST dataset to detect handwritten numbers.

The MNIST dataset of handwritten digits has a training set of 60,000 examples, and a test set of 10,000 examples:

![Example-images-from-the-MNIST-dataset](https://user-images.githubusercontent.com/44135514/215034545-58986030-d9df-4999-9d24-8e794a9fd28c.png)

## Setup

_mnist_train.csv_ is pretty big and Github cannot version control it. So in order to run training you have to unzip the _mnist_train_csv.zip_ file in the same folder where it is currently placed.

## Run

To train the network and update the weights from the _DetectNumbersCore_ folder run:
```
python Sources/TrainCore.py
```
And wait for some time depending on your hardware.
