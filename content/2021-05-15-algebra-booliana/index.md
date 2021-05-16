+++
title = "Álgebra booliana"

[taxonomies]
series = []
tags = ["Matemática"]
linguagens = []
+++

Há algum tempo, quando a [bug_elseif](https://www.twitch.tv/bug_elseif) ainda estava fazendo [listas de exercícios em Python](https://wiki.python.org.br/ListaDeExercicios), apareceu um problema que envolvia verificar se um ano era bissexto ou não. Embora a construção de uma expressão para verificar se um ano é bissexto seja até intuitiva, como estávamos utilizando a condição invertida (verificar se o ano não era bissexto), sua construção não estava sendo fácil, porém é possível usar um pouco de matemática para chegar nela.

## Construção da expressão

Primeiramente vamos construir uma expressão para verificar se um ano é bissexto. Para isso, ele deve ser múltiplo de 4, porém se o ano terminar com 00, ele também deve ser múltiplo de 400. Para verificar se um número termina com 00, basta verificar se ele é múltiplo de 100, e para verificar se um número é múltiplo de outro, podemos verificar o resto da divisão ou módulo (quem sabe falo sobre matemática modular em outro artigo), caso o resultado dessa operação seja 0, o primeiro número é divisível pelo segundo, e caso seja qualquer outro valor, o primeiro número não é divisível pelo segundo (ou não possui uma divisão inteira).

Assim, a expressão para verificar se o ano é bissexto pode ser construída como:

```txt
(ano % 4 == 0 && ano % 100 != 0) || ano % 400 == 0
```

A primeira coisa a ser observada é que existem duas subexpressões com o conectivo disjuntivo ("ou" `||`), ou seja, para um ano ser bissexto basta ele cumprir uma das duas condições (subexpressões). A primeira condição também é dividida em outras duas subexpressões, porém dessa vez com o conectivo conjuntivo ("e" `&&`), assim é necessário que as duas condições sejam verdadeiras para que o seu valor seja considerado verdadeiro, onde a primeira verifica se o ano é divisível por 4 (resto da divisão é igual a 0), e a segunda verifica se ele não é divisível por 100 (resto da divisão é diferente de 0). Essa é a primeira possibilidade para um ano ser bissexto. A outra possibilidade é se ele for divisível por 400 (resto da divisão é igual a zero).

Assim, essa expressão retorna verdadeiro se o ano for bissexto, e falso caso ele não for.

## Invertendo a expressão

Porém na ocasião, a expressão que estávamos usando deveria retornar verdadeiro caso o ano não fosse bissexto, e falso caso ele fosse bissexto (o contrário da expressão apresentada). Isso poderia ser feito negando a expressão anterior, ou escrevendo uma expressão de tal forma que retorne o oposto, e era justamente essa segunda opção que estávamos tentando fazer.

Entretanto, existe uma forma matemática de trabalhar com a negação da expressão, alteando-a até que ela chegue próximo ou a exata expressão que estávamos construindo. Isso é possível através de propriedades das operações boolianas, substituindo parte da expressão a cada vez que uma propriedade por aplicada. Sendo as mais comuns para esse tipo de operação as propriedades de negação da negação (`!!a = a`), distributiva (`a || (b && c) = (a || b) && (a || c)` e `a && (b || c) = (a && b) || (a && c)`, que lembra a distributiva da matemática `2 * (3 + 4) = (2 * 3) + (2 * 4)`), e as leis de De Morgan (`!(a || b) = !a && !b` e `!(a && b) = !a || !b`). Para mais propriedades veja a página sobre o assunto na [Wikipédia](https://pt.wikipedia.org/wiki/Álgebra_booliana).

Para esse caso é necessário aplicar apenas as leis de De Morgan. Partindo da negação da expressão, aplicando-a passo a passo, temos:

```txt
!((ano % 4 == 0 && ano % 100 != 0) || ano % 400 == 0)
!(ano % 4 == 0 && ano % 100 != 0) && !(ano % 400 == 0)
(!(ano % 4 == 0) || !(ano % 100 != 0)) && !(ano % 400 == 0)
(ano % 4 != 0 || ano % 100 == 0) && ano % 400 != 0
```

Onde essa última expressão é a que precisávamos para o código.

## Considerações

Álgebra booliana é interessante para trabalhar condições como de `if` e laços de repetições dos códigos, seja para otimizá-la ou inverter os blocos de código do `if` e `else`, por exemplo, o que pode ser utilizado para deixar o código mais fácil de entender, colocando os blocos de código em uma ordem que faça mais sentido para a leitura. Ela também pode ser utilizada para facilitar a construção de expressões, como no caso apresentando, onde é muito mais fácil e intuitivo escrever uma expressão que verifica se o ano é bissexto do que um ano que não é, onde essa última pode até ser contraintuitiva, onde a álgebra booliana permite partir da expressão mais fácil para a mais difícil.

E para quem quiser se aprofundar nesse assunto, recomendo as [aulas do RiverFount](https://www.youtube.com/playlist?list=PL8iUCCJD339ezAJWqFaKriz_9tyBw6hE-), que é professor de filosofia.
