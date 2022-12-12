+++
title = "Discussão sobre o Advent of Code 2022 - Dia 6: Otimizando o algoritmo e utilização de estruturas de dados"

[taxonomies]
series = ["Advent of Code"]
tags = ["Desempenho", "Otimização"]
linguagens = ["Python"]
+++

O sexto dia do [Advent of Code deste ano](https://adventofcode.com/2022) tem um problema interessante para discutir sobre otimização do algoritmo e utilização de estruturas de dados.

## O problema do dia 6

O problema do dia 6 ["problema de sintonização"](https://adventofcode.com/2022/day/6) consiste em encontrar uma subsequência onde não existam elementos repetidos. Recomendo tentar resolvê-lo primeiro.

## Solução simples

Uma forma simples de resolver os problemas no Advent of Code é encontrar soluções simples que não tenham grandes complicações. Para esse problema, uma solução baseada em força bruta, que consiste em testar todas as possíveis subsequências, atende esse requisito. Ela pode ser implementada percorrendo a entrada do problema, extraindo as subsequências e verificando se nelas todos os elementos são únicos, esse último pode ser feito utilizando a estrutura de conjuntos (comentado no problema do [dia 3](@/2022-12-06-advent-of-code-2022-dia-03/index.md)) verificando se o tamanho do mesmo é igual da subsequência, uma vez que a estrutura de conjuntos "remove" elementos duplicados. Exemplo:

```python
from itertools import count

tamanho = 4
for i in count():
    subsequencia = entrada[i:i + tamanho]
    if len(set(entrada[i:i + tamanho])) == tamanho:
        # resposta encontrada
```

## 1ª Questão - Desempenho

A solução apresentada funciona, porém ela percorre toda a entrada, e para cada posição da entrada, precisa executar mais uma quantidade de operações igual ao tamanho da subsequência desejada (`O(n * tamanho)`). Isso pode deixar esse algoritmo cada vez mais lento conforme se deseja uma subsequência maior.

O ideal seria um algoritmo que conseguisse depender apenas do tamanho da entrada (`O(n)`), para isso é preciso desenvolver algum mecanismo para guardar quais caracteres estão na subsequência, verificar se o novo caractere lido está nela ou não e descartar o caractere que saiu da subsequência ao ler esse novo caractere da entrada, tudo isso em tempo constante (`O(1)`). Se pensarmos em guardar a posição que tal caractere apareceu pela última vez, é fácil responder se ele se encontra dentro ou já está fora da subsequência olhando pelo tamanho dela e posição do caractere lido. E ao guardamos a posição em que a última duplicidade foi encontrada é fácil determinarmos quantos caracteres foram lidos sem duplicidade, desta forma, ao atingir o tamanho desejado, a resposta é encontrada. Juntando esses pensamentos, temos o seguinte algoritmo:

```python
tamanho = 4
posicao_das_letras = {}
ultima_duplicidade = -1
for i, c in enumerate(entrada):
    if posicao_das_letras.get(c, -1) > ultima_duplicidade:
        ultima_duplicidade = posicao_das_letras.get(c, -1)
    else:
        if i - ultima_duplicidade == tamanho:
            # resposta encontrada
    posicao_das_letras[c] = i
```

Considerando que a implementação de dicionário do Python utiliza uma [tabela de espalhamento](https://pt.wikipedia.org/wiki/Tabela_de_dispers%C3%A3o), e que as operações para guardar e recuperar um valor espera-se que ocorram em tempo constante (`O(1)`), temos como resultado um algoritmo em tempo linear (`O(n)`).

## 2ª Questão - Estrutura de dados

Porém tabelas de espalhamento podem ter problemas com colisão de hash, além de ter uma implementação relativamente complexa. Como nesse problema existe um conjunto relativamente restrito de chaves, 256 caracteres considerando todos os valores possíveis em 1 Byte (ou ainda 26 caracteres, considerando apenas as letras de `a` até `z`), e que esses valores podem ser facilmente interpretados como números, é possível utilizar uma simples lista no lugar do dicionário, usando a posição da lista como sua chave. Exemplo:

```python
tamanho = 4
posicao_das_letras = [-1 for _ in range(256)]
ultima_duplicidade = -1
for i, c in enumerate(ord(c) for c in entrada):
    if posicao_das_letras[c] > ultima_duplicidade:
        ultima_duplicidade = posicao_das_letras[c]
    else:
        if i - ultima_duplicidade == tamanho:
            # resposta encontrada
    posicao_das_letras[c] = i
```

Desta forma é utilizado uma estrutura de dados muito mais simples, e obtendo o mesmo resultado. Essa abordagem também não vai ter problemas com colisão de hash, e nem problemas com o tempo de cálculo do mesmo, uma vez que não utiliza funções de hash, deixando o algoritmo menos suscetível a problemas.

Um outro desafio que observei onde a utilização de estruturas de dados mais simples é possível foi no [2376 da beecrowd](https://www.beecrowd.com.br/repository/UOJ_2376.html), que se resume a montar uma chave de um campeonato, dizendo no final o vencedor. Por ter uma estrutura visual bastante semelhante a uma árvore, um primeiro impulso resolvê-lo implementando uma, porém olhando a sequência dos jogos, é possível resolver esse problema utilizando uma fila, e que pode ser até mais fácil de implementar uma vez que não é necessário se preocupar em que profundidade da árvore está se processando.

## Considerações

Nem todo problema é possível resolver em tempo linear, e quando é, pode-se exigir um pouco mais de estudo sobre o problema e busca da melhor estrutura de dados.
