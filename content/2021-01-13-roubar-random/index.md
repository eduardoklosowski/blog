+++
title = "Como roubar no random?"

[taxonomies]
tags = ["metaprogramação", "segurança"]
linguagens = ["python"]
+++

Recentemente o [vitthin](https://www.twitch.tv/vitthin) implementou o comando `!amizade <username>` em seu bot, que recebe o nome de outro usuário como parâmetro, respondendo no chat uma porcentagem randômica para qual seria sua amizade com aquela pessoa, apenas por diversão (e algumas brigas também, quem sabe?). Porém os resultados estavam questionáveis, principalmente se não existiria algum `if` no código para favorecer ou desfavorecer determinados usuários.

Existe um problema sobre a distribuição dos valores randômicos, principalmente quando se utiliza o resto da divisão, como demonstrado [neste artigo](https://bitismyth.wordpress.com/2020/02/14/o-problema-da-solucao-ingenua-da-obtencao-de-valores-aleatorios/). Porém isso só é observado quando se tem muitas execuções, e não é uma manipulação ativa do valor randômico, como estávamos questionando.

Para demonstrar que era possível manipular a mensagem enviada pelo bot, sem que isso apareça no código, eu fiz a demonstração a baixo:

{{ asciinema(id="383797") }}

Ou seja, é possível fazer essa manipulação. A questão que o [vitthin](https://www.twitch.tv/vitthin) não conseguiu responder foi: como isso foi feito?

## Como manipular o código?

### Através do decorador

Na própria live, enquanto estávamos discutindo, eu comentei que o decorador utilizado na função implementada pelo [vitthin](https://www.twitch.tv/vitthin) poderia manipular o resultado. Algo como o código a baixo:

```python
def decorator(funcao):
    def wrapper():
        return 'Tchau'
    return wrapper

@decorator
def cumprimentar():
    return 'Oi'

print(cumprimentar())  # Resultado: Tchau
```

Ou como demonstrado pelo Fernando Masanori:

{{ youtube(id="Wnc6McPpmUg") }}

Com esse método, é realmente possível alterar o comportamento do código, porém fica explícito no código a existência desse decorador, o que pode facilmente levantar suspeitas. Porém não foi o caso da minha demonstração, uma vez que eu também mostro o código desse decorador, e não tem nada lá fazendo essa manipulação.

### Alterar a biblioteca padrão

Em outra demonstração também feita pelo Fernando Masanori, ele altera a biblioteca padrão do Python, no caso alterando o código da função `randint`:

{{ youtube(id="0KU2ntx0MZc") }}

Com esse método também é possível alterar o comportamento do código, mas diferente do anterior, não deixa explícito a manipulação que foi feita. Porém na minha demonstração, o comportamento da função muda conforme o nome de usuário informado, o qual não é acessível dentro da função `randint`, apenas se mudasse a assinatura da função para receber o nome do usuário também, mas isso seria visível no código, então não seria possível fazer a mesma coisa que na demonstração.

### Alterar de onde carregar bibliotecas

Durante uma apresentação no FISL 14, o Cascardo comentou sobre o desafio de fazer um programa Java aceitar outro certificado (começando a discussão aos 23:05), onde de 26:43 até 28:50 ele comentou como trocou a classe utilizada pelo Java, retomando ao assunto aos 37:29 até 37:55:

{{ video(url="http://hemingway.softwarelivre.org/fisl14/high/41b/sala41b-high-201307031502.ogg") }}

Essa opção funciona para o Java (pergunto se funcionaria para o Kotlin também [morgiovanelli](https://www.twitch.tv/morgiovanelli)?). No Python, esse comportamento pode ser replicado utilizando a variável de ambiente [`PYTHONPATH`](https://docs.python.org/3/using/cmdline.html?highlight=pythonpath#envvar-PYTHONPATH), bastando criar uma cópia alterada da biblioteca em outro lugar, e informando isso nessa variável de ambiente quando fosse executado o código.

Esse método também permite alterar o comportamento do código, mas apenas para bibliotecas em outros diretórios, como a biblioteca padrão e de terceiros, o que é demonstrado a baixo pela ordem de precedência dos diretórios, onde a string vazia (`''`) representa o diretório atual:

```python
import sys
from pprint import pprint

pprint(sys.path)
# Resultado:
# ['',
#  '/home/eduardo/pythonlibmod',
#  '/usr/lib/python37.zip',
#  '/usr/lib/python3.7',
#  '/usr/lib/python3.7/lib-dynload',
#  '/usr/local/lib/python3.7/dist-packages',
#  '/usr/lib/python3/dist-packages']
```

Em relação ao código da minha demonstração, ele só permitiria alterar a função `randint`, que como já foi discutido, não permitiria repetir o mesmo comportamento da demonstração. Como a biblioteca `lib` encontra-se no mesmo diretório da aplicação, não seria possível utilizar esse método para alterá-la.

### Comprometendo o kernel

Outra técnica seria comprometendo o sistema, alterando diretamente o kernel onde o código é executado, como feito pelo Seth Schoen numa apresentação no FISL 15 dos 25:17 até 33:03:

{{ video(url="http://hemingway.softwarelivre.org/fisl15/high/40t/sala40t-high-201405071559.ogv") }}

Definitivamente esse método permite alterar o comportamento do código e é o mais difícil de se detectar. Porém no final da minha demonstração eu usei o próprio Python para ler e exibir o arquivo, então seria possível reproduzir o comportamento do código, porém a alteração seria visível ao imprimir o código na tela pelo Python.

### Edição de vídeo

É possível que o comportamento da minha demonstração seja uma edição de vídeo, ainda mais que ele foi gravado com o asciinema, bastando trocar os resultados conforme desejado, visto que ele está em *plaintext* no [arquivo](https://asciinema.org/a/383797.cast?dl=1). Porém isso não seria aplicável ao chat na Twitch, como estava sendo usado, apenas no vídeo.

## Como foi feito

Para fazer isso, eu primeiramente olhei no `python -h`, onde foi possível encontrar algumas opções interessantes para interagir como o interpretador do Python, onde o parâmetro [`PYTHONSTARTUP`](https://docs.python.org/3/using/cmdline.html?highlight=pythonstartup#envvar-PYTHONSTARTUP) permitiria que código de outro lugar fosse executádo automaticamente, sem que fosse visto na tela.

Desta forma fiz o seguinte [código](codigo.tar.gz), que para executá-lo basta entrar no diretório `botmod/meubot` e rodar `PYTHONSTARTUP=../editlib.py python3`, ou ainda definir a variável de anteriormente, com `export PYTHONSTARTUP=../editlib.py`, assim ao executar `python3` o meu script carregaria a biblioteca e faria [monkey patching](https://pt.stackoverflow.com/questions/285190/o-que-%C3%A9-monkey-patch#305084) para aplicar a alteração na `lib` (o que lembra da discussão sobre macacos digitando na live da [bug_elseif](https://www.twitch.tv/bug_elseif)).

## Considerações

A minha demonstração é verdadeira e facilmente reproduzível, sem a utilização de algum recurso como edição de vídeo. Embora não foi possível fazer a mesma demonstração com os outros métodos mostrados, eles também permitem fazer manipulação no comportamento do código, podendo serem utilizados em outros casos. A área de metaprogramação trabalha bastante com técnicas apresentadas, e recomendo [essa palestra](http://hemingway.softwarelivre.org/fisl14/high/41d/sala41d-high-201307031001.ogg) sobre o assunto.

É importante observar também as implicações de segurança das demonstrações. Na mesma apresentação do Seth, ele comenta outras questões bastante interessantes, como aos 19:00 sobre a possibilidade do compilador inserir falhas de segurança nos programas, ou erros como descrito aos 13:38, que podem atingir linguagens de mais alto nível como o próprio Python. Também sobre uma falha de segurança no OpenSSH, que a correção consistia na diferença de apenas um bit no código binário. Vale observar também que muitas vezes um programa malicioso pode não ter permissão para fazer alguma operação, mas se aproveitar de permissões incorretas de arquivos e diretórios (principalmente `chmod 777`) para criar códigos, que poderiam ser executados sem perceber por outros usuários, onde esses teriam permissão para fazer a operação.

Felizmente ou infelizmente não é possível para um terceiro alterar o comportamento do random de um bot diretamente com o uso desses métodos, ele precisaria de acesso ao ambiente onde o código é executado, mas é possível para o dono do bot.
