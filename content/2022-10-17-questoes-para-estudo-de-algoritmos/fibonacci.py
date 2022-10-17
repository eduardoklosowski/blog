import gc
from time import process_time_ns


def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n - 2) + fibonacci(n - 1)


def fibonacci_iterativo(n):
    a = 0
    b = 1
    for i in range(n - 1):
        a, b = b, a + b
    return b


if __name__ == '__main__':
    print('alg,n,tempo')
    for n in range(1, 36):
        for i in range(10):
            gc.disable()
            inicio = process_time_ns()
            fibonacci(n)
            tempo = process_time_ns() - inicio
            gc.enable()
            print(f'recursivo,{n},{tempo}')

            gc.disable()
            inicio = process_time_ns()
            fibonacci_iterativo(n)
            tempo = process_time_ns() - inicio
            gc.enable()
            print(f'iterativo,{n},{tempo}')
