+++
title = "Discussão sobre o Advent of Code 2022 - Dia 10: Divisão de responsabilidades em geradores"

[taxonomies]
series = ["Advent of Code"]
tags = ["Code Style", "Async"]
linguagens = ["Python"]
+++

No décimo dia do [Advent of Code de 2022](https://adventofcode.com/2022) tem um problema interessante para discutir sobre divisão de responsabilidades de funções geradoras.

## O problema do dia 10

O problema do dia 10, ["tubo de raios catódicos"](https://adventofcode.com/2022/day/10), consiste em implementar um emulador simples. Na parte 1 deve ser feito a decodificação e execução de instruções de um processador, enquanto na parte 2 deve-se implementar uma saída de vídeo. Recomendo tentar resolvê-lo primeiro.

## Resolução da parte 1

A parte 1 pede para ler as instruções da entrada, executá-las considerando a quantidade de ciclos que cada tipo de instrução leva, e em determinados ciclos fazer um calculo para obter a resposta, guardando o resultado em um acumulador. Nessa descrição podem ser identificado três responsabilidades diferentes: ler e tratar as instruções da entrada; controlar a execução das instruções no processador e seus ciclos necessários; e controlar o ciclo atual, fazendo o cálculo do valor desejado. Uma forma de escrever funções separando essas responsabilidades é utilizando geradores do Python, que como eles permitem executar um trecho de código, parar e voltar depois, isso permite com que cada função foque apenas na sua responsabilidade, sem precisar misturá-las.

A função para tratar a entrada pode ser feita como um gerador que lê um arquivo e retorna cada instrução com seus valores já convertidos (quando a instrução possui valores extras). No caso da instrução `noop`, seria apenas a informação que é uma instrução [NOOP](https://pt.wikipedia.org/wiki/NOP). Enquanto a instrução `addx` tem também um valor inteiro a ser somado no registrador `x`. Segue um exemplo onde cada valor retornado pelo gerador é uma lista contendo a instrução na primeira posição e o inteiro associado a ela, quando presente, na segunda posição:

```python
def ler_instrucoes(entrada):
    for linha in entrada:
        instrucao = linha.strip().split(' ')
        if len(instrucao) >= 2:
            instrucao[1] = int(instrucao[1])
        yield instrucao
```

Esse gerador permite com que a entrada possa ser carregada e tradada conforme as instruções forem sendo executadas, não sendo necessário carregar tudo para a memória, nem tratar toda a entrada primeiro, antes de seguir para a próxima parte do problema. Além de simplificar o processo para quem for executar as operações, onde não será necessário se preocupar com conversão de tipos, por exemplo.

A execução das instruções também pode ser feita através de um gerador. Como um gerador permite executar um trecho de código e parar, isso pode ser utilizado para simular os ciclos do processador, onde cada valor retornado pelo gerador (`yield`) representar o estado no processador naquele ciclo, que nesse problema se resume ao valor do registrador `x`, que pode ser implementado como uma variável local da função geradora. Segue um exemplo de código:

```python
def processador(instrucoes):
    x = 1
    for instrucao in instrucoes:
        if instrucao[0] == 'noop':
            yield x
        elif instrucao[0] == 'addx':
            yield x
            yield x
            x += instrucao[1]
```

Essa função itera sobre um conjunto de instruções recebida como argumento (gerador apresentado anteriormente) e executa essas instruções. No caso de instruções `noop`, nada é feito, porém o `yield x` faz com que o gerador pare nesse ponto, sendo necessário a leitura do próximo valor do gerador do processador para a continuação da execução desse código, simulando o ciclo do processador. Já as instruções `addx`, como possuem dois `yield x`, faz com que seja necessário mais leitura de valores para que finalmente o valor da instrução seja adicionado ao registrador `x`, simulando o processador parado dois ciclos, para só no final deles a instrução ser completada.

Com a decodificação das instruções e o processador feitos, basta instanciar um gerador da função `ler_instrucoes` e um da função `processador`, passando o primeiro como argumento para o segundo. Como o segundo gerador é o responsável por iterar sobre o primeiro (ele faz um `for` nesse iterador), basta iterar sobre o segundo para simular os ciclos e execução das instruções, e ao utilizar um [`enumerate`](https://docs.python.org/pt-br/3/library/functions.html#enumerate) é possível saber em que ciclo a execução se encontra e realizar as operações desejadas para se calcular o valor pedido pelo problema. Segue um exemplo de código:

```python
p = processador(ler_instrucoes(open('entrada.txt')))
total = 0
for i, x in enumerate(p, start=1):
    if (i - 20) % 40 == 0:
        total += i * x
    if i == 220:
        break
print(total)
```

## Resolução da parte 2

Entendido como decodificar as instruções e controlar os ciclos para a execução das mesmas, a parte 2 pede para simular uma tela de tubo de raios catódicos. Essa tela possui algumas regras, como mostrar um pixel por vez, e a cada 40 pixeis, ir para a linha a baixo, reiniciando o processo. Isso também pode ser implementado como um gerador, encapsulando essas regras, porém em vez de retornar valores, ele deve receber valores, o que também é chamado de consumidor, mas tem a mesma sintaxe, com a diferença que em vez de usar `yield x` para retornar um valor `x`, é usado `x = yield` para guardar numa variável o valor recebido, e ainda continua possuindo a função de parar a execução do código, nesse caso aguardando o próximo valor. Segue um exemplo de implementação:

```python
def crt():
    while True:
        for i in range(40):
            x = yield
            if x - 1 <= i <= x + 1:
                print('\u2588', end='')
            else:
                print(' ', end='')
        print()
```

Essa função é um *loop* infinito, que percorre 40 valores imprimindo na tela um [bloco preenchido](https://unicodeplus.com/U+2588) ou um espaço (fiz essa mudança uma vez que facilitou a visualização do resultado), conforme o valor do registrador `x` recebido, e após isso faz uma quebra de linha.

Como as funções `ler_instrucoes` e `processador` já estão implementadas, e não é necessário nenhuma alteração em suas lógicas, basta acoplar o consumidor `crt` com elas para ter o resultado desejado. Porém como ao criar um gerador, nenhum código do mesmo é executado até que seu primeiro valor seja lido, é necessário instanciar o consumidor `crt` e fazer uma primeira execução para que o mesmo pare no `yield` e esteja pronto para receber o primeiro valor, o que pode ser feito utilizando a função [`next`](https://docs.python.org/pt-br/3/library/functions.html#next), assim como é possível fazer para recuperar um valor do gerador. Segue um exemplo dessa implementação:


```python
tela = crt()
next(tela)
for x in processador(ler_instrucoes(open('entrada.txt'))):
    tela.send(x)
```

## Considerações

A utilização de geradores permitiu a implementação do código separando responsabilidades em diferentes funções, além de encapsular regras de controle do processador numa função e da tela em outra, sem misturar as duas coisas, deixando-as desacopladas e que poderiam ser utilizadas separadamente. E embora as lógicas estejam separadas, a execução intercala elas, como se o código fosse um *loop* que lê uma instrução, executado ela e mostrado na tela o caractere resultante, para então repetir essas ações, o que permite ser eficiente em relação ao uso de memória, como já comentado anteriormente nessa série.

Geradores também são a forma como corrotinas ou funções assíncronas eram feitas em Python antes deles entrarem como um recurso da linguagem, recomendo a série ["Geradores e uma Introdução histórica à corrotinas com Python"](https://www.youtube.com/playlist?list=PLOQgLBuj2-3J4IRxalwXhRMU6UPoaigf9) do [Dunossauro](https://twitter.com/dunossauro) sobre o assunto.
