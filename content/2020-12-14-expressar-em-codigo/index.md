+++
title = "Diferentes formas de expressar em código"

[taxonomies]
tags = ["Code Style"]
linguagens = ["Rust"]
+++

Existem diferentes formas de se programar algo, mesmo quando usa-se a mesma linguagem de programação. Embora esses códigos possam ser considerados equivalentes, uma vez que apresentam o mesmo resultado, eles tem suas particularidades, podendo facilitar ou dificultar sua leitura e manutenção. Usando como exemplo a impressão dos valores de uma lista (ou array) no terminal utilizando a linguagem [Rust](https://www.rust-lang.org/pt-BR/), pretendo mostrar essas diferenças na prática, de forma que também possa ser abstraído para outras lógicas e linguagens.

## Problema proposto

Dado uma lista:

```rust
let lista = [1, 6, 3, 8, 4, 3];
```

Deseja-se imprimir no terminal o índice e valor de cada elemento, conforme a baixo:

```txt
0 => 1
1 => 6
2 => 3
3 => 8
4 => 4
5 => 3
```

Uma forma de se resolver esse problema é iterando sobre os elementos da lista, imprimindo os índices e valores.

## Código 1: Acesso direto

Uma primeira forma de resolver esse problema é acessando cada valor diretamente no código. Exemplo:

```rust
println!("{} => {}", 0, lista[0]);
println!("{} => {}", 1, lista[1]);
println!("{} => {}", 2, lista[2]);
println!("{} => {}", 3, lista[3]);
println!("{} => {}", 4, lista[4]);
println!("{} => {}", 5, lista[5]);
```

Esse código é simples e direto, tendo como resultado da sua execução o resultado desejado. Porém apresenta dois pontos principais: ele é fixo para 6 elementos, sendo necessário sua alteração caso a quantidade de elementos da lista seja alterado; também existe uma repetição no código, sendo necessário alterar todos os `println!(...)` caso deseja-se mudar a saída.

## Código 2: `while`

É possível escrever o código de forma que ele se adapte a quantidade de elementos da lista, sendo necessário uma estrutura de repetição para isso. Exemplo:

```rust
let mut i = 0;
while i < lista.len() {
    println!("{} => {}", i, lista[i]);
    i += 1;
}
```

Esse código utiliza a estrutura de repetição `while` para melhorar os dois pontos destacados no código anterior, verificando o tamanho da lista em tempo de execução, e evitando a repetição do `println!(...)`. Porém isso vem com o custo adicional de uma variável e alguns ciclos de processamento adicionais para fazer o controle da estrutura de repetição (acessar o tamanho da lista e compará-lo a variável de controle).

## Código 3: `for`

Outra forma possível é a utilização da estrutura de repetição `for`. Exemplo:

```rust
for i in 0..lista.len() {
    println!("{} => {}", i, lista[i]);
}
```

Esse código, assim como o anterior, necessita de uma variável para o controle da estrutura de repetição. Entretanto, o controle desta variável fica a cargo da linguagem e não do programador, não sendo necessário incrementá-lo manualmente, e fica mais claro no código como a estrutura de repetição está sendo controlada. Um ponto negativo é que não é possível alterar essa variável diretamente, o que possibilitaria imprimir os valores em outra ordem, com alguma lógica mais elaborada, como seria possível no Código 2.

## Código 4: Iterando com `for`

Em Rust é possível iterar diretamente os valores de uma lista utilizando o `for`. Exemplo:

```rust
for &v in lista.iter() {
    println!("_ => {}", v);
}
```

Embora esse seja o código mais simples usando uma estrutura de repetição, e fica claro no código de que a interação está ocorrendo em cima dos valores da lista, não é possível mostrar o índice do valor no `println!(...)`.

## Código 5: Iterando com `for` e `.enumerate()`

Para permitir que o índice seja mostrado, é possível enumerar os valores da lista. Desta forma, em vez de iterar nos elementos da lista diretamente, o `for` itera em tuplas com o valor dado pelo `.enumerate()` e o elemento da lista. Exemplo:

```rust
for (i, &v) in lista.iter().enumerate() {
    println!("{} => {}", i, v);
}
```

Esse código se assemelha ao anterior em simplificação, porém permitindo que o índice seja impresso no terminal. Embora ele seja bem parecido com o Código 3, seu `for` deixa claro que a estrutura de repetição está iterando sobre os valores da lista, enquanto o `for` do Código 3 apenas diz que está sendo iterado sobre seus índices, necessitando verificar o bloco de código do `for` para entender no que o índice está sendo usado, e necessitando acessar manualmente os valores da lista, o que poderia dificultar a alteração do nome da variável da lista, por exemplo, uma vez que o mesmo precisaria ser alterado em diversos lugares.

## Código 6: `.for_each()`

Rust também permite que o código seja feito utilizando funções em vez de uma estrutura de repetição (embora a estrutura de repetição seja usada internamente por essas funções). Para esse caso foi utilizado a função `.for_each()` do iterador, que permite chamar uma função passada por argumento para cada valor da lista. Exemplo:

```rust
lista
    .iter()
    .enumerate()
    .for_each(|(i, &v)| println!("{} => {}", i, v));
```

Esse código está dividido em várias linhas apenas para facilitar sua leitura, podendo estar em uma única linha. O compilador do Rust também consegue otimizar esse código deixando-o mais performático que a versão utilizando o `for`. Porém a versão com `for` deixa explícito no código a iteração dos elementos da lista, o que poderia facilitar a sua leitura. Nesse código também não é possível utilizar comandos como `continue` e `break` para controlar a estrutura de repetição, necessitando utilizar outras [funções do iterador](https://doc.rust-lang.org/std/iter/trait.Iterator.html#required-methods) para comportamentos distintos.

## Considerações

Com exceção do Código 4, todos os outros têm o mesmo resultado no terminal, sendo opções de código viáveis de resolução do problema proposto. Cada código possui suas diferenças, variando em legibilidade e flexibilidade. Pensando em percorrer os elementos da lista para resolver o problema, essa lógica pode ser expressa de diferentes formas, como visto nos diferentes códigos apresentados, assim como em português é possível transmitir uma mesma ideia com diferentes frases.

Abstraindo para um sistema, existem diferentes formas de resolver as pequenas partes do sistema, e muitas vezes essas pequenas partes podem apresentar similaridades. Quando essas partes são resolvidas utilizando a mesma técnica, isso pode facilitar a leitura e manutenção do código, uma vez que fica mais fácil de pressupor o que o código está fazendo conforme o programador se habitua com ele. Assim como, ao se terminar uma alteração, é possível fazer uma análise, verificando se não existe uma melhor forma de expressar a lógica já implementada, deixando o código mais organizado, o que facilitaria a leitura do mesmo.
