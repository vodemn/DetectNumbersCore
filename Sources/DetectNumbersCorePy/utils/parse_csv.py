import csv
import string
import numpy as np


def parse_csv(filename: string):
    inputs = []
    targets = []
    with open('Sources/Dataset/' + filename + '.csv', newline='') as csvfile:
        rows = csv.reader(csvfile, delimiter='\n')
        for i, row in enumerate(rows):
            if (i > 0):
                values = row[0].split(",")
                inputs.append([int(value) / 255 for value in values[1:]])
                targets.append(__int_to_one_hot(int(values[0])))
    inputs = np.array(inputs).T
    targets = np.array(targets).T
    return (inputs, targets)


def __int_to_one_hot(n: int) -> np.array:
    v = [0] * 10
    v[n] = 1
    return np.array(v)
