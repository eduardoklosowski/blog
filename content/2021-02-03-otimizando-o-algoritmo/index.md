+++
title = "Otimizando o algoritmo passo a passo"

[taxonomies]
tags = ["otimização"]
linguagens = ["php"]
+++

Acompanhando as lives da [bug_elseif](https://www.twitch.tv/bug_elseif), no meia das [listas de exercícios que ela estava fazendo](https://wiki.python.org.br/ListaDeExercicios) tem um exercício pedindo para verificar se um número informado pelo usuário é primo ou não. No chat, muitos faziam sugestões para que o primeiro código feito já fosse o mais otimizado possível, e isso é interessante quando já se sabe a solução do problema. Porém quando não se sabe essa solução, seria possível chegar nela também? É possível otimizar o código pouco a pouco?

## Primeira solução

A solução mais simples possível é fazer um algoritmo que leia um número, e verifique se ele é divisível apenas por 1 e por ele mesmo (condição para um número ser primo). Para verificar se um número é divisível por outro, basta verificar o resto da divisão, se o resto da divisão for 0, significa que o primeiro número é divisível pelo segundo, se for diferente de 0, o primeiro número não é divisível pelo segundo. Para verificar a divisibilidade do número lido por todos os números, basta testar número por número da sequência de 1 até o número lido, contando a quantidade de vezes que foi possível dividi-lo. Se ao final desse processo, o número foi divisível apenas por dois números (1 e ele mesmo), ele é primo, caso tenha sido dividido por mais de dois números, ele não é primo.

Para implementar esse algoritmo foi escolhida a linguagem [PHP](https://www.php.net/) em homenagem ao matemático [pokemaobr](https://www.twitch.tv/pokemaobr), que inclusive falou numa live que já esteve em uma competição de código mais eficiente para verificar se um número é primo durante a faculdade. A implementação dessa primeira solução é:

```php
#!/usr/bin/env php
<?php
$stdin = fopen('php://stdin', 'r');

echo 'Digite um número: ';
$numero = trim(fgets($stdin));

$divisores = 0;
for ($i = 1; $i <= $numero; $i++) {
    if ($numero % $i == 0) {
        $divisores += 1;
    }
}

if ($divisores == 2) {
    echo "O número $numero é primo!\n";
} else {
    echo "O número $numero não é primo!\n";
}

fclose($stdin);
```

Para executar esse código, basta salvá-lo no computador, atribuir permissão de execução (exemplo: `chmod +x verificaprimo`), e executá-lo (`./verificaprimo`), visto que a primeira linha já informa ao sistema qual interpretador deve ser utilizado (essa linha é chamada de [shebang](https://pt.wikipedia.org/wiki/Shebang)). Caso essa linha não existisse, seria necessário chamar o código através do interpretador do PHP de forma explícita (`php verificaprimo`).

Em relação a eficiência, esse código verificará exatamente o mesmo número de divisões do número lido para dar a resposta se o número informado é primo ou não.

## Segunda solução

A primeira solução funciona, porém para quem olha o código, existe um número mágico (`$divisores == 2`), que é proveniente da definição (o número deve ser divisível apenas por 1 e por ele mesmo), porém não faz muito sentido para quem não sabe ou não lembra do raciocínio que resulta nesse número. Como todos os números serão divisíveis por 1 e por ele mesmo, não é necessário fazer essa verificação, que pode ser assumida.

Para remover a verificação da divisibilidade pelo 1 e pelo próprio número, é necessário alterar a condição no `for` e ajustar o `if` final, considerando casos especiais que surgem com essa solução. Essas melhorias podem ser verificadas a baixo:

```php
#!/usr/bin/env php
<?php
$stdin = fopen('php://stdin', 'r');

echo 'Digite um número: ';
$numero = trim(fgets($stdin));

$divisores = 0;
for ($i = 2; $i < $numero; $i++) {
    if ($numero % $i == 0) {
        $divisores += 1;
    }
}

if ($divisores == 0 && $numero != 0 && $numero != 1) {
    echo "O número $numero é primo!\n";
} else {
    echo "O número $numero não é primo!\n";
}

fclose($stdin);
```

Em relação a eficiência, essa solução precisa fazer dois testes de divisibilidade a menos que a primeira solução, portanto um pouco mais eficiente, visto que não é necessário fazer a operação de divisão nesses casos (apenas a comparação). Porém não resolve de fato o problema do número mágico utilizado no código, apenas troca `2` por `0`, o que já fica um pouco mais simples de ler, mas ainda é um número mágico para quem não acompanhar a lógica.

## Terceira solução

Considerando que agora o algoritmo precisa verificar apenas se o contador `$divisores` foi incrementado alguma vez, é possível trocá-lo por um booleano. Para esse booleano fazer mais sentido, é possível utilizá-lo para dizer o estado do número, assumindo que ele é primo, até descobrir um divisor que prove que ele não é primo, resultando a seguinte implementação:

```php
#!/usr/bin/env php
<?php
$stdin = fopen('php://stdin', 'r');

echo 'Digite um número: ';
$numero = trim(fgets($stdin));

$primo = true;
for ($i = 2; $i < $numero; $i++) {
    if ($numero % $i == 0) {
        $primo = false;
    }
}

if ($primo && $numero != 0 && $numero != 1) {
    echo "O número $numero é primo!\n";
} else {
    echo "O número $numero não é primo!\n";
}

fclose($stdin);
```

Essa solução remove totalmente o número mágico. Em relação a eficiência, a quantidade de verificações continua a mesma. Mas enquanto a segunda solução precisava ler o valor do contador `$divisores`, somar e guardar o novo valor nessa variável, nessa solução só o último passo (atribuir valor) é executado.

## Quarta solução

Entretanto a terceira solução, mesmo após descobrir um caso que prova que o número lido não é primo, continua verificando todos os possíveis divisores. Porém uma vez que é descoberto um caso que prova que o número não é primo, não é necessário continuar verificando os demais. No código isso pode ser visto na variável `$primo`, que uma vez definida como `false`, não existe uma condição que a faça voltar para `true`, sendo possível criar uma interrupção no fluxo de execução (`break`), saindo do `for` sem verificar os demais divisores. Essa implementação fica assim:

```php
#!/usr/bin/env php
<?php
$stdin = fopen('php://stdin', 'r');

echo 'Digite um número: ';
$numero = trim(fgets($stdin));

$primo = true;
for ($i = 2; $i < $numero; $i++) {
    if ($numero % $i == 0) {
        $primo = false;
        break;
    }
}

if ($primo && $numero != 0 && $numero != 1) {
    echo "O número $numero é primo!\n";
} else {
    echo "O número $numero não é primo!\n";
}

fclose($stdin);
```

A eficiência do código continua a mesma para quando o número for primo. Porém quando o número não for primo, assim que for identificado o primeiro divisor, já se terá a resposta.

## Quinta solução

Considerando que a divisão pode ser desfeita ([função inversa](https://pt.wikipedia.org/wiki/Fun%C3%A7%C3%A3o_inversa)) através de uma multiplicação, é possível descrever esse problema como a busca por dois números inteiros que multiplicados tem como resultado o número lido (`a * b == $numero`), também conhecido como [fatoração](https://pt.wikipedia.org/wiki/Fatora%C3%A7%C3%A3o). Testar todos os possíveis divisores, significa testar todos esses valores como `a` e verificar se o valor usado para `b` seria um número inteiro, onde o valor de `b` diminuirá conforme o valor de `a` crescer para que o número lido como resultado da multiplicação. Considerando a propriedade da comutatividade da multiplicação (`a * b == b * a`), existirá um ponto onde os valores de `a` e `b` são iguais e depois dele serão testados novamente as multiplicações já feitas, apenas trocando os valores de `a` e `b`. O ponto onde esses valores são iguais é a raiz do número lido (`sqrt($numero) * sqrt($numero) == $numero`), então só seria necessário verificar até ele, e não até o valor lido:

```php
#!/usr/bin/env php
<?php
$stdin = fopen('php://stdin', 'r');

echo 'Digite um número: ';
$numero = trim(fgets($stdin));

$primo = true;
for ($i = 2; $i <= sqrt($numero); $i++) {
    if ($numero % $i == 0) {
        $primo = false;
        break;
    }
}

if ($primo && $numero != 0 && $numero != 1) {
    echo "O número $numero é primo!\n";
} else {
    echo "O número $numero não é primo!\n";
}

fclose($stdin);
```

Essa solução mantém a mesma eficiência para números não primos da anterior. Mas melhora para os números primos, visto que reduz os divisores testados.

## Sexta solução

Embora a solução anterior seja boa, e muitos acabem sugerindo ela, existe algo a ser observado nela. Para cada vez que o `for` é executado, sua condição de repetição é avaliada, e assim calcula-se novamente a raiz do número (`$i <= sqrt($numero)`). O valor da raiz poderia ser guardado em uma variável, e utilizada essa variável para a comparação, visto que o resultado dessa função não muda conforme a execução do código, o que evitaria recalculá-la a cada verificação. Ficando assim:

```php
#!/usr/bin/env php
<?php
$stdin = fopen('php://stdin', 'r');

echo 'Digite um número: ';
$numero = trim(fgets($stdin));

$primo = true;
$raiz = sqrt($numero);
for ($i = 2; $i <= $raiz; $i++) {
    if ($numero % $i == 0) {
        $primo = false;
        break;
    }
}

if ($primo && $numero != 0 && $numero != 1) {
    echo "O número $numero é primo!\n";
} else {
    echo "O número $numero não é primo!\n";
}

fclose($stdin);
```

## Outras soluções

Ainda existem outras otimizações possíveis. Sabendo que o 2 é o único número primo par, seria possível verificar a divisão por ele, e após isso só testar divisores ímpares, reduzindo assim pela metade a quantidade de divisores testados (considerando também a otimização da raiz quadrada):

```php
#!/usr/bin/env php
<?php
$stdin = fopen('php://stdin', 'r');

echo 'Digite um número: ';
$numero = trim(fgets($stdin));

$primo = true;
if ($numero != 2 && $numero % 2 == 0) {
    $primo = false;
} else {
    $raiz = sqrt($numero);
    for ($i = 3; $i <= $raiz; $i += 2) {
        if ($numero % $i == 0) {
            $primo = false;
            break;
        }
    }
}

if ($primo && $numero != 0 && $numero != 1) {
    echo "O número $numero é primo!\n";
} else {
    echo "O número $numero não é primo!\n";
}

fclose($stdin);
```

Essas são otimizações considerando apenas o código. Ainda é possível considerar a arquitetura do computador onde ele será executando, buscando instruções mais rápida, ou que consomem menos energia (aumentando o tempo de bateria), para aquele processador. Outro tipo de otimização seria tentar reduzir a quantidade de memória utilizada, por exemplo, utilizando a variável que guarda o resultado para raiz como a variável de controle do `for`, percorrendo os números de forma inversa, como nessa implementação:

```php
#!/usr/bin/env php
<?php
$stdin = fopen('php://stdin', 'r');

echo 'Digite um número: ';
$numero = trim(fgets($stdin));

$primo = true;
for ($i = floor(sqrt($numero)); $i > 1; $i--) {
    if ($numero % $i == 0) {
        $primo = false;
        break;
    }
}

if ($primo && $numero != 0 && $numero != 1) {
    echo "O número $numero é primo!\n";
} else {
    echo "O número $numero não é primo!\n";
}

fclose($stdin);
```

## Considerações

Foi possível, partindo de uma solução não otimizada, fazer pequenas otimizações e chegar a uma solução bastante otimizada. Esse processo pode ser repetido em qualquer código, basta fazer uma solução simples que funciona, após isso estudar como melhorá-la, o que é um bom incentivo para voltar para o código depois dele ter funcionado.

Algumas otimizações melhoraram a legibilidade do código, deixando-o muito mais simples de entender posteriormente, removendo valores que parecem ser arbitrários do código (números mágicos). Enquanto outras otimizações aumentam a complexidade, criando uma escolha entre ter um código mais performático, ou mais fácil de entender.

Ainda sobre esse assunto, eu recomendo a palestra do Jon "MadDog" Hall no FISL 15, "Performance: More Than Just Speed":

{{ video(url="http://hemingway.softwarelivre.org/fisl15/high/40t/sala40t-high-201405081059.ogv") }}
