# DetectNumbersCore

## About

This package implements a neural network trained on MNIST dataset to detect handwritten numbers.

The MNIST dataset of handwritten digits has a training set of 60,000 examples, and a test set of 10,000 examples:

![MNIST dataset](https://www.researchgate.net/profile/Steven-Young-5/publication/306056875/figure/fig1/AS:393921575309346@1470929630835/Example-images-from-the-MNIST-dataset.png)

## Setup

_mnist_train.csv_ is pretty big and Github cannot version control it. So in order to run training you have to unzip the _mnist_train_csv.zip_ file in the same folder where it is currently placed.

## Run

To train the network and update the weights from the _DetectNumbersCore_ folder run:
```
python Sources/TrainCore.py
```
And wait for some time depending on your hardware.