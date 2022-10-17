import gc
from time import process_time_ns


def fatorial(n):
    if n <= 1:
        return 1
    return n * fatorial(n - 1)


def fatorial_iterativo(n):
    valor = 0
    for i in range(1, n + 1):
        valor *= i
    return valor


if __name__ == '__main__':
    print('alg,n,tempo')
    for n in range(1, 36):
        for i in range(10):
            gc.disable()
            inicio = process_time_ns()
            fatorial(n)
            tempo = process_time_ns() - inicio
            gc.enable()
            print(f'recursivo,{n},{tempo}')

            gc.disable()
            inicio = process_time_ns()
            fatorial_iterativo(n)
            tempo = process_time_ns() - inicio
            gc.enable()
            print(f'iterativo,{n},{tempo}')
