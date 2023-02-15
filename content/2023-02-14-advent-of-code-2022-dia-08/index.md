+++
title = "Discussão sobre o Advent of Code 2022 - Dia 8: Valor da constante de um algoritmo linear"

[taxonomies]
series = ["Advent of Code"]
tags = ["Desempenho", "Otimização"]
linguagens = ["Python"]
+++

No oitavo dia do [Advent of Code de 2022](https://adventofcode.com/2022) tem um problema interessante para discutir sobre o termo constante na complexidade de um algoritmo.

## O problema do dia 8

O problema do dia 8, ["casa nas copas das árvores"](https://adventofcode.com/2022/day/8), consiste em analisar as alturas das árvores e contá-las. Na parte 1 isso deve ser feito olhando de fora da floresta, enquanto na parte 2 deve-se olhar do topo de cada árvore. Recomendo tentar resolvê-lo primeiro.

## Resolução da parte 1

A parte 1 do problema pergunta quantas árvores são visível de fora da floresta. É possível resolvê-lo com um algoritmo de complexidade linear ao número de árvores, e uma das formas de fazer isso é analisando a partir de cada orientação (norte, sul, leste e oeste) guardando quais foram as árvores visíveis para não contar a mesma árvore mais de uma vez. Isso faz com que todas as árvores sejam analisadas quatro vezes (uma vez a partir de cada direção), mas mesmo percorrendo todas as árvores quatro vezes, não tira a característica linear do algoritmo, uma vez que a complexidade `O(4*n)` é considerado igual a `O(n)`, só mudando a constante que multiplica a complexidade, e essa constante normalmente é omitida na notação.

Um exemplo de implementação desse algoritmo pode ser visto a baixo, onde é possível percorrer todas as direções mexendo nos laços das variáveis `x` e `y`:

```python
entrada = [[int(i) for i in line.rstrip()] for line in open(0)]

largura = len(entrada[0])
altura = len(entrada)

arvores_visiveis = set()

# Análise do oeste para leste
for y in range(altura):
    maior_tamanho = -1
    for x in range(largura):
        tamanho = entrada[y][x]
        if tamanho > maior_tamanho:
            arvores_visiveis.add((x, y))
            maior_tamanho = tamanho

# Análise do leste para o oeste
for y in range(altura):
    maior_tamanho = -1
    for x in reversed(range(largura)):
        tamanho = entrada[y][x]
        if tamanho > maior_tamanho:
            arvores_visiveis.add((x, y))
            maior_tamanho = tamanho

# Análise do norte para o sul
for x in range(largura):
    maior_tamanho = -1
    for y in range(altura):
        tamanho = entrada[y][x]
        if tamanho > maior_tamanho:
            arvores_visiveis.add((x, y))
            maior_tamanho = tamanho

# Análise do sul para o norte
for x in range(largura):
    maior_tamanho = -1
    for y in reversed(range(altura)):
        tamanho = entrada[y][x]
        if tamanho > maior_tamanho:
            arvores_visiveis.add((x, y))
            maior_tamanho = tamanho

print(len(arvores_visiveis))
```

Ainda seria possível fazer uma otimização, como verificar se o maior tamanho de árvore já foi encontrado, o que impediria de encontrar outra árvore visível naquela linha ou coluna, e nesse caso o laço mais interno poderia ser interrompido (`if maior_tamanho == 9: break`). Isso pode reduz o número de análises para alguns problemas, mas não reduz a complexidade do algoritmo, que continua sendo linear, até porque essa otimização não vai conseguir melhorar o desempenho para todas as entradas, um caso é uma entrada que não tenha árvores de altura 9, por exemplo.

Também é possível utilizar outra matriz para guardar as árvores visíveis em vez do conjunto utilizado no exemplo (`set()`), iniciando todas as árvores como não visíveis e quando se encontra uma visível, troca-se seu estado. E para saber quantas árvores são visíveis bastaria percorrer essa segunda matriz para contá-las, o que faria ser necessário percorrer a matriz mais uma vez, porém ainda manteria a complexidade linear do algoritmo.

## Resolução da parte 2

Na parte 2 do problema, a visibilidade deve ser feita a partir de cada árvore. Uma implementação simples disso é olhar as quatro direções para cada árvore. Considerando `l` a quantidade de árvores de leste para oeste e `h` de note para sul, a complexidade dessa solução simples seria `O(n*l)` ou `O(n*h)`, o que for maior. Porém existe um algoritmo capaz de resolver esse problema de forma linear (`O(n)`).

Para resolver esse problema de forma linear são necessários ajustes na estratégia da parte 1, uma vez que a mudança do referencial pode fazer com que árvores que não eram visíveis antes se tornem visíveis, ou que eram visíveis não sejam mais. Uma estratégia é considerar todas as alturas possíveis para cada árvore que está sendo analisada, somando 1 no contador dessa possível altura caso seja visível, ou reiniciando o contador caso a visão esteja obstruída, e na hora de analisar uma direção, fazer isso de trás para frente. Assim é possível dizer para cada árvore sua visão naquela direção, e aproveitar esses dados para o cálculo de visão de cada próxima árvore. E para o cálculo da pontuação de cada árvore, como é a multiplicação da visibilidade nas quatro direções, pode-se iniciar com pontuação 1 para cada árvore e ir multiplicando conforme se calcula a visibilidade nas direções.

Um exemplo desse algoritmo pode ser visto a baixo:

```python
entrada = [[int(i) for i in line.rstrip()] for line in open(0)]

largura = len(entrada[0])
altura = len(entrada)
tamanhos = 10

pontuacoes = [[1 for _ in range(largura)] for _ in range(altura)]

for y in range(altura):
    tamanho_anterior = -1
    visibilidade_anterior = [-1 for _ in range(tamanhos)]
    for x in range(largura):
        tamanho = entrada[y][x]
        visibilidade = []
        for i in range(tamanhos):
            if i > tamanho_anterior:
                visibilidade.append(visibilidade_anterior[i] + 1)
            else:
                visibilidade.append(1)
        pontuacoes[y][x] *= visibilidade[tamanho]
        tamanho_anterior = tamanho
        visibilidade_anterior = visibilidade

for y in range(altura):
    tamanho_anterior = -1
    visibilidade_anterior = [-1 for _ in range(tamanhos)]
    for x in reversed(range(largura)):
        tamanho = entrada[y][x]
        visibilidade = []
        for i in range(tamanhos):
            if i > tamanho_anterior:
                visibilidade.append(visibilidade_anterior[i] + 1)
            else:
                visibilidade.append(1)
        pontuacoes[y][x] *= visibilidade[tamanho]
        tamanho_anterior = tamanho
        visibilidade_anterior = visibilidade

for x in range(largura):
    tamanho_anterior = -1
    visibilidade_anterior = [-1 for _ in range(tamanhos)]
    for y in range(altura):
        tamanho = entrada[y][x]
        visibilidade = []
        for i in range(tamanhos):
            if i > tamanho_anterior:
                visibilidade.append(visibilidade_anterior[i] + 1)
            else:
                visibilidade.append(1)
        pontuacoes[y][x] *= visibilidade[tamanho]
        tamanho_anterior = tamanho
        visibilidade_anterior = visibilidade

for x in range(largura):
    tamanho_anterior = -1
    visibilidade_anterior = [-1 for _ in range(tamanhos)]
    for y in reversed(range(altura)):
        tamanho = entrada[y][x]
        visibilidade = []
        for i in range(tamanhos):
            if i > tamanho_anterior:
                visibilidade.append(visibilidade_anterior[i] + 1)
            else:
                visibilidade.append(1)
        pontuacoes[y][x] *= visibilidade[tamanho]
        tamanho_anterior = tamanho
        visibilidade_anterior = visibilidade

maior_pontuacao = 0
for y in range(altura):
    for x in range(largura):
        pontuacao = pontuacoes[y][x]
        if pontuacao > maior_pontuacao:
            maior_pontuacao = pontuacao
print(maior_pontuacao)
```

Esse algoritmo também percorre todas as árvores quatro vezes para calcular a visibilidade, porém toda vez que analisa uma árvore em uma determinada direção, o faz dez vezes, uma para cada tamanho possível, resultando em 40 análises por árvore (`O(40*n)`), além de percorrer todas as árvores uma vez a mais para encontrar a maior pontuação. Como a quantidade de tamanhos possíveis é fixa, não variando conforme a entrada do problema, isso não muda a complexidade do algoritmo, que se mantem linar (`O(n)`). Também seria possível calcular a maior pontuação junto do cálculo da visibilidade da última direção, isso removeria o último laço do algoritmo, porém só deslocaria as instruções da comparação da pontuação de um laço para o outro, cada instrução ainda precisaria ser executada (menos as instruções de controle do laço de repetição), não tendo grandes ganhos de desempenho e misturaria coisas diferentes no laço, o que o deixaria mais difícil de ler.

Outra coisa que pode ser observada nesse algoritmo é a quantidade de memória necessária para executá-lo. Ele cria uma cópia da matriz para guardar a pontuação calculada, e quando está calculando as direções, precisa manter um contador diferente para cada tamanho possível. E diferente da parte 1 onde é possível guardar só as árvores visíveis, o que reduz o consumo de memória ao usar um conjunto (`set`) para isso, na parte 2 é necessário guardar a pontuação parcial de cada árvore, uma vez que não é possível calcular a pontuação final de cada árvore, uma a uma, sem mexer na complexidade do algoritmo, mas isso permitiria guardar em memória apenas a maior pontuação encontrada até então, por exemplo.

## Considerações

Foi possível encontrar algoritmos com complexidade linear para as partes desse problema, porém devido ao fato de ter uma quantidade de direções e tamanhos fixos para o problema. Se tivesse variações como para certas entradas incluir visibilidade nas diagonais também e para outras entradas não, ou mudar a diferença entre a maior e menor altura das árvores, isso teria que aparecer como uma variável multiplicando a complexidade do algoritmo, e não como uma constante, já que isso alteraria a quantidade de análises que precisariam ser feitas.

Como esses algoritmos têm complexidade linear de execução, isso os tornam uma boa opção para grandes entradas. Porém caso as entradas sejam pequenas, um algoritmo com complexidade superior poderia rodar mais rápido devido as grandes constantes que multiplicam a complexidade das soluções lineares. Isso deve ser levado em consideração na hora da escolha do algoritmo a ser utilizado para resolver o problema.

Para esses algoritmos foi necessário carregar toda a matriz em memória, uma vez que os dados eram lidos diversas vezes, e em diversas ordens. Assim não foi possível ler a entrada sob-demanda para reduzir o consumo de memória como nos problemas dos dias anteriores. Se o tamanho da entrada fosse muito grande, impossibilitando guardar tudo em memória, ainda seria possível guardar os dados em arquivos, calculando a posição do dado a ser lido ou escrito e usando funções como [`seek`](https://docs.python.org/3/library/io.html#io.IOBase.seek) para ir direto para o dado desejado, mas considerando que o acesso ao HD ou SSD é mais lento que a memória RAM, isso deixaria a execução mais lenta. E nesse caso talvez outros algoritmos, mesmo com complexidades maiores poderiam lidar melhor com esse problema.
