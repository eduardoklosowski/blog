+++
title = "Discussão sobre o Advent of Code 2022 - Dia 2: Sequência de condições"

[taxonomies]
series = ["Advent of Code"]
tags = ["Desempenho", "Otimização"]
linguagens = ["Python", "Rust"]
+++

Segundo dia do [Advent of Code deste ano](https://adventofcode.com/2022), na questão de optimização do algoritmo, ele tem bastante semelhança com o [dia 1](@/2022-12-01-advent-of-code-2022-dia-01/index.md) sobre tratar a entrada, mas tem uma questão que acredito que vale uma observação no seu processamento.

## O problema do dia 2

O problema do dia 2 ["pedra papel tesoura"](https://adventofcode.com/2022/day/2) consiste basicamente em transcrever as [regras do jogo de mesmo nome](https://pt.wikipedia.org/wiki/Pedra,_papel_e_tesoura) para um algoritmo que processe seus resultados. Novamente recomendo que tentem resolver o desafio primeiro, e o vídeo do [Bruno Rocha](https://twitter.com/rochacbruno):

{{ youtube(id="jANYXhnDsZM") }}

## Questão - Sequência de condições

Na solução apresentada pelo Bruno Rocha foi utilizado o `match` do Rust para definir a pontuação ganha em cada rodada. Nem todas as linguagens têm essa estrutura de controle (ou um `switch ... case` que poderia substituí-lo em alguns casos), mas é possível fazer algo similar utilizando `if`. Exemplo:

```python
if oponente == 'A' and voce == 'X':
    score += 0
elif oponente == 'A' and voce == 'Y':
    score += 0
elif oponente == 'A' and voce == 'Z':
    score += 0
elif oponente == 'B' and voce == 'X':
    score += 0
elif oponente == 'B' and voce == 'Y':
    score += 0
elif oponente == 'B' and voce == 'Z':
    score += 0
elif oponente == 'C' and voce == 'X':
    score += 0
elif oponente == 'C' and voce == 'Y':
    score += 0
elif oponente == 'C' and voce == 'Z':
    score += 0
```

Um ponto dessa abordagem é que para resultados que tem sua condição verificada mais no início, como `A X`, tendem a ser computados mais rápido que condições verificadas mais para o final, como `C Z`. Dependendo do ambiente, se confidencialidade for importante, por exemplo, medir o tempo de cálculo poderia vazar quais foram as opções escolhidas, quebrando a confidencialidade (mas não é o caso aqui). Isso pode ser contornado trocando todos os `elif` para `if`, o que faria todas as opções ficarem mais lentas iguais, já que toda vez todas as condições seriam verificadas.

Mas considerando reduzir o tempo de execução, usar `if` aninhados é uma outra abordagem possível. Exemplo:

```python
if oponente == 'A':
    if voce == 'X':
        score += 0
    elif voce == 'Y':
        score += 0
    elif voce == 'Z':
        score += 0
elif oponente == 'B':
    if voce == 'X':
        score += 0
    elif voce == 'Y':
        score += 0
    elif voce == 'Z':
        score += 0
elif oponente == 'C'
    if voce == 'X':
        score += 0
    elif voce == 'Y':
        score += 0
    elif voce == 'Z':
        score += 0
```

Assim, em vez de ter que passar por 9 condições até chegar na opção `C Z` (pior caso), seriam necessário apenas 6 condições, sendo que as demais combinações também tem ganhos.

Outra abordagem em vez de usar `if`, como o Bruno comentou, seria utilizando estruturas como mapas ou dicionários (o nome varia de acordo com a linguagem). Exemplo:

```python
scores = {
    ('A', 'X'): 0,
    ('A', 'Y'): 0,
    ('A', 'Z'): 0,
    ('B', 'X'): 0,
    ('B', 'Y'): 0,
    ('B', 'Z'): 0,
    ('C', 'X'): 0,
    ('C', 'Y'): 0,
    ('C', 'Z'): 0,
}

score += scores[oponente, voce]
```

O desempenho dessa solução depende da estrutura de dados utilizada para implementar o mapa/dicionário. Se ele for implementado em cima de uma [árvore de busca binária](https://pt.wikipedia.org/wiki/%C3%81rvore_bin%C3%A1ria_de_busca) (algo com alguma semelhante a uma [`BTreeMap` do Rust](https://doc.rust-lang.org/std/collections/struct.BTreeMap.html)) teria um desempenho semelhante a solução de `if` anilhados, se for implementado em cima de uma [tabela de espalhamento](https://pt.wikipedia.org/wiki/Tabela_de_dispers%C3%A3o) (estrutura [`HashMap` do Rust](https://doc.rust-lang.org/std/collections/hash_map/struct.HashMap.html)) se resumiria a calcular um hash em cima dos dados e acessar diretamente o valor desejado, o que poderia ser um desempenho ótimo para todas as condições, só dependendo da eficiência do cálculo da hash.

Olhando para a questão do Rust agora, é possível que `BTreeMap` tenha um desempenho melhor do que o `HashMap`, por ser poucos dados e não precisar chamar a função de hash. E sobre o `match`, não sei como ele foi implementado na linguagem, se ele seguiria uma ordem sequencial, como na primeira abordagem mostrada, ou se conseguiria fazer alguma otimização como no `if` aninhado. Porém para as poucas condições do problema a diferença no tempo seria mínima.

## Considerações

Nos exemplos foram utilizados valores 0, por não ser o foco da discussão, e seus valores mudar na parte 1 e 2, mas uma implementação real para resolver o problema traria os pontos ganhos em cada condição.

Para um universo de 9 possibilidades diferentes, como no problema do dia 2 do Advent of Code, qualquer uma das soluções apresentadas vai conseguir atender. Porém isso não muda o fato de algumas serem mais otimizadas que outras, e que a lógica utilizada poderiam ser reaproveitada, e que conseguiriam lidar melhor com problemas onde existem muito mais possibilidades a serem analisadas.

Também existe uma discussão se seria mais eficiente tratar a string inteira (`'A X'`), ou processar isso e tratar como tuplas (`('A', 'X')`). Em outros casos poderia ser tratar direto a string, ou converter para um número inteiro. Quanto menos conversões necessárias melhor, porém as vezes isso poderia mudar a complexidade de uma operação como comparação, o que valeria pagar o custo para converter o dado.

Infelizmente no Python não existe a possibilidade de escolher a implementação do dicionário, ele sempre funcionará como uma tabela de espalhamento, e por isso valores que não podem ser convertidos para hash não podem ser utilizados como chaves ([documentação oficial](https://docs.python.org/pt-br/3/library/stdtypes.html#mapping-types-dict)).

E todas essas otimizações fazem pouquíssima diferença para esse problema, mas essas mesmas ideias podem ser aplicadas a outros problemas e lá trazerem diferenças significativas. Estou usando esse problema só como desculpa para falar desses detalhes.
