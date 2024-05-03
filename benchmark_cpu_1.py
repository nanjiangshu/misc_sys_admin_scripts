import time
import numpy as np

size_of_vec = 10000000

def pure_python_version():
    t1 = time.time()
    X = range(size_of_vec)
    Y = range(size_of_vec)
    Z = [X[i] + Y[i] for i in range(len(X))]
    return time.time() - t1

def numpy_version():
    t1 = time.time()
    X = np.arange(size_of_vec)
    Y = np.arange(size_of_vec)
    Z = X + Y
    return time.time() - t1


t1 = pure_python_version()
t2 = numpy_version()
print("Pure python version: {:0.4f} seconds".format(t1))
print("Numpy version:       {:0.4f} seconds".format(t2))
print("Numpy is in this example {:0.1f} times faster!".format(t1/t2))