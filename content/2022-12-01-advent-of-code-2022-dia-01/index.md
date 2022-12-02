+++
title = "Discussão sobre o Advent of Code 2022 - Dia 1: Processando lista de valores"

[taxonomies]
series = ["Advent of Code"]
tags = ["Desempenho", "Otimização"]
linguagens = ["Python"]
+++

Começou o [Advent of Code deste ano](https://adventofcode.com/2022), que embora tenha uma competição de quem resolve primeiro os problemas propostos, também é uma oportunidade para se desafiar e treinar o entendimento e a resolução de problemas. Porém aqui não quero discutir como resolver os problemas, mas sim pensar sobre os algoritmos usados para resolvê-los.

## O problema do dia 1

Para quem não viu, ou se quiser relembrar, o problema do dia 1 é o ["contando calorias"](https://adventofcode.com/2022/day/1), e que consiste basicamente de somar grupos de números e encontrar as maiores somas.

Recomendo primeiramente tentar resolver esse problema. Se tiver dificuldades, ou se quiser ter uma ideia melhor da linha de pensamento que vou usar como base da discussão, recomendo o vídeo do [Bruno Rocha](https://twitter.com/rochacbruno):

{{ youtube(id="lzD2geCWjB4") }}

## 1ª Questão - Uso de memória

Muitas soluções mais simplistas e rápidas de se programar acabam criando várias cópias dos valores em memória, por exemplo: guardando todo o conteúdo do arquivo de entrada em uma variável, criando uma lista (ou array) com todo os valores, outra lista com os valores convertidos para inteiro, outra com a soma dos valores... Para exemplificar em Python, seria algo como:

```python
entrada1 = open('entrada.txt').read()
entrada2 = entrada.strip().split('\n\n')
entrada3 = [e.split() for e in entrada2]
entrada4 = [[int(f) for f in e] for e in entrada3]
entrada5 = [sum(e) for e in entrada4]
...
```

Nesse exemplo estou exagerando em criar várias variáveis, muitas dessas instruções poderiam ser feitas juntas de outras, economizando algumas linhas (e variáveis também). Porém a questão que quero apontar aqui é que todos os dados são carregados para a memória do computador de uma vez só, e depois são criadas várias cópias ligeiramente diferentes do mesmo dado (convertido de string para inteiro, lista da soma dos valores no lugar da lista de lista...).

Isso pode ser um problema quando existem muitos dados para tratar, como no caso de arquivos com gigabytes de dados, ou quando se tem uma quantidade limitada de memória RAM, como em um dispositivo embarcado ou um AWS Lambda. E isso continua sendo um problema mesmo reduzindo a quantidade de cópias dos valores para duas, ou até mesmo uma única cópia em memória, só será necessário mais dados para o problema ocorrer.

A solução apresentada pelo Bruno Rocha é bastante interessante nesse ponto, que pelo menos para a parte 1 do problema, vai lendo, processando e descartando dados conforme eles são e deixam de ser necessários, com a exceção da entrada que é lida inteira, mas poderia ser adaptada para uma solução com um buffer que leia poucos bytes por vez, ou conforme for necessário. O código dele se aproveita bastante das funcionalidades do Rust para isso, mas também é possível fazer algo semelhante sem essas funcionalidades, ou em outras linguagens, exemplo:

```python
max_calorias = 0
calorias = 0
for linha in open('entrada.txt'):
    linha = linha.strip()
    if linha == '':
        max_calorias = max(calorias, max_calorias)
        calorias = 0
    else:
        calorias += int(linha)
max_calorias = max(calorias, max_calorias)
print(max_calorias)
```

Nessa solução apresentada ainda existe alguma duplicidade de valores na memória, como ter ao mesmo tempo o valor como string e inteiro, mas se limita apenas ao que está sendo tratando no momento e não tudo, não usa nenhuma lista, por exemplo. Ela também permite tratar arquivos de qualquer tamanho com pouca memória RAM, até mesmo com uma quantidade de memória RAM menor do que o tamanho do arquivo de entrada.

Entretanto a parte 2 do problema exige um pouco mais de memória, já que não busca só o maior valor, vou discutir sobre isso junto com a próxima questão.

## 2ª Questão - Ordenação

A parte 2 do problema pede a soma dos 3 maiores valores, uma forma de resolver isso é gerar uma lista com as somas dos valores, ordenar eles e pegar os 3 maiores. Além dessa solução precisar de mais memória conforme a quantidade de valores, ela também irá ordenar todos os valores, sendo que precisamos apenas dos 3 primeiros (ou últimos, dependendo da lógica e ponto de vista). Isso é um problema porque algoritmos de ordenação tendem a ter complexidade ciclomática `O(n * log2(n))`, que basicamente diz que o tempo para ordenar os valores cresce (demora mais para rodar) conforme tem mais valores para ordenar (`n` é igual a quantidade de valores nesse caso), devido a maior quantidade de comparações de valores necessárias para isso.

Considerando [a entrada presente no problema](https://adventofcode.com/2022/day/1/input), são 241 somas que devem ser ordenadas para se buscar as 3 maiores, isso da algo em torno da grandeza de 1900 comparações (`241 * log2(241)`) para se ordenar essa lista com um algoritmo como o [quick sort](https://pt.wikipedia.org/wiki/Quicksort), que é largamente utilizado. Porém olhando o [bubble sort](https://pt.wikipedia.org/wiki/Bubble_sort), que embora seja conhecidamente mais lento que o quick sort na maioria dos casos, e por isso normalmente não utilizado quando se precisa de desempenho, ele permite interromper sua execução logo após a ordenação dos 3 valores desejados, sem precisar ordenar desnecessariamente os demais. Exemplo:

```python
valores = [...]
for i in range(3):
    for j in range(i + 1, len(valores)):
        if valores[j] > valores[i]:
            aux = valores[i]
            valores[i] = valores[j]
            valores[j] = aux
print(valores[:3])
```

Isso faria a ordenação apenas dos 3 valores desejados com 717 comparações, algo em torno da grandeza de `O(3 * n)`, sendo 3 o número de valores desejados (`3 * 241 = 723` apenas para comparação). Desta forma são menos comparações que o quick sort, e bem menos do que as 28920 comparações que a execução completa do bubble sort levaria.

Entretanto o problema aqui está no tamanho da lista a ser ordenada. Imagine que se em vez de ordenar a lista só no final, toda vez que um valor fosse inserido na lista isso já fosse feito de forma ordenada, e descartando os valores desnecessários (menores que os 3 maiores já encontrados até aquele momento). Isso reduziria muito a lista a ser ordenada (4 valores, os 3 maiores e o valor sendo processado), e sabendo que os valores que estão na lista já estão ordenados, não é necessário ordená-los novamente, só inserir o novo valor no local certo. Desta forma seria necessário menos comparações, o código rodaria mais rápido, e com o descarte dos valores menores, voltaria a ser possível executá-lo com uma quantidade reduzida de memória RAM.


## Considerações

Nesse texto discuti sobre variações de algoritmos que resolvem o problema visando tempo de execução e consumo de memória, que é um foco diferente da competição do Advent of Code em si, que é de quem dá a resposta certa mais próximo da liberação do problema. Também é diferente do foco das competições de programação que visam apenas tempo de execução (e não consideram uso de memória).

Para a competição do Advent of Code, uma solução mais rápida de programar pode ser mais interessante, mesmo que em alguns casos ela demore mais para executar, visto que a velocidade do processador pode compensar o tempo que uma pessoa levaria para pensar e implementar um algoritmo mais otimizado. Isso mostra que dependendo da onde for utilizado, nem sempre uma solução mais otimizada para o computador é a melhor.

Outro ponto positivo de participar do Advent of Code são os exercícios de tentar entender o problema e de tentar pensar em como representar os dados para que um algoritmo possa processá-los, mesmo sem conseguir encontrar a resposta, só de pensar nas estruturas de dados e organização deles pode ser um ótimo exercício.

Eu não pretendo fazer uma análise dessa de cada dia, até porque são bastantes problemas, e os mais avançados tendem a ser mais complexos e misturar várias coisas. Esses pontos que levantei provavelmente vão se repetir nos próximos problemas, o que ficaria redundante também. Mas volto a escrever outro texto se eu observar alguma questão que seja interessante trazer para a discussão.
