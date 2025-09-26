+++
title = "Branch para deploy de validação"

[taxonomies]
series = []
tags = ["Git", "Procedimento"]
linguagens = []
+++

Em um projeto de software é comum precisar testar uma funcionalidade que está sendo ou foi desenvolvida. Nos projetos em que o código roda em um servidor, isso pode envolver o deploy em algum ambiente específico, permitindo assim testar uma versão específica do código interagindo com as aplicações cliente ou demais serviços. Porém quando mais de uma funcionalidade é desenvolvida ao mesmo tempo em branches diferentes do git, muitas vezes por pessoas diferentes, testar duas ou mais funcionalidades ao mesmo tempo pode não ser trivial.

## Exemplificando o problema

Um fluxo bastante comum usado no git é criar uma branch para desenvolver uma funcionalidade. Quando essa funcionalidade estiver pronta, e preferencialmente testada, é feito o merge para a branch principal do projeto. Isso permite que diferentes funcionalidades sejam desenvolvidas em paralelo, seguindo cada uma as etapas do seu fluxo de trabalho, sem ou com a menor interferência possível, assim como também permite desistir do desenvolvimento de uma funcionalidade ou recomeçá-lo.

Um exemplo de diferentes branches do git pode ser visto a baixo:

{% mermaid() %}
gitGraph
    commit id: "0"
    branch feature-1
    commit id: "1"
    commit id: "2"
    checkout main
    branch feature-2
    commit id: "3"
    commit id: "4"
{% end %}

Se considerar que o projeto é o código de uma API Rest que é executado em um servidor, e que existem alguns ambientes diferentes como:

- `Produção`: ambiente em que o projeto está de fato sendo utilizado. Deploy realizado a partir da branch `main`.
- `Homologação`: ambiente para validação antes de ir para produção. Deploy realizado a partir da branch `main`.
- `Desenvolvimento`: ambiente para testar as coisas pelos desenvolvedores, sem necessariamente se comprometer em levar para produção o que é feito aqui. Deploy realizado a partir de qualquer branch.

Caso as pessoas que desenvolveram as branches `feature-1` e `feature-2` queiram testar seus códigos no ambiente `Desenvolvimento`, apenas uma versão (branch) poderá ser testada por vez, já que ao realizar o deploy da versão do commit `4`, ele substituirá o deploy da versão do commit `2`, por exemplo, e vice-versa.

## Proposta de solução

Uma forma de abordar esse problema é através da criação uma versão com todas as funcionalidades que se deseja testar. No git isso pode ser feito criando outra branch para reunir as branches desejadas (fazer merge delas). Por exemplo, executando os seguintes comandos:

```sh
git checkout -b desenvolvimento main
git merge --no-ff feature-1
git merge --no-ff feature-2
```

O que geraria o seguinte histórico no git:

{% mermaid() %}
gitGraph
    commit id: "0"
    branch feature-1 order: 2
    commit id: "1"
    commit id: "2"
    checkout main
    branch feature-2 order: 3
    commit id: "3"
    commit id: "4"
    checkout main
    branch desenvolvimento order: 1
    merge feature-1 id: "5"
    merge feature-2 id: "6"
{% end %}

Assim ao realizar o deploy no ambiente `Desenvolvimento` sempre a partir da branch `desenvolvimento`, isso permite testar todas as funcionalidades desejadas ao mesmo tempo, nesse caso as funcionalidades presentes nas branches `feature-1` e `feature-2`. Porém essas funcionalidades ainda terão suas respectivas branches separadas para continuar seu fluxo de trabalho, como abertura de pull request (PR) ou merge request (MR), revisão de código e demais etapas que podem existir sem se misturar com as outras, não se importando com a branch `desenvolvimento`.

A branch `desenvolvimento` ainda poderá receber novas funcionalidades de outras branches, alterações das branches que já havia feito o merge anteriormente. Ou seja, novas versões podem ser feitas nessa branch conforme a necessidade. Um exemplo é um teste de alteração na `feature-1` (commit `7`), que foi feito o merge e deploy (versão no commit `8`), e se não teve o resultado esperado, poderá ser revertido:

{% mermaid() %}
gitGraph
    commit id: "0"
    branch feature-1 order: 2
    commit id: "1"
    commit id: "2"
    checkout main
    branch feature-2 order: 3
    commit id: "3"
    commit id: "4"
    checkout main
    branch desenvolvimento order: 1
    merge feature-1 id: "5"
    merge feature-2 id: "6"
    checkout feature-1
    commit id: "7"
    checkout desenvolvimento
    merge feature-1 id: "8"
    commit id: "REVERTE-8" type: REVERSE
{% end %}

### Entrega das funcionalidades

Quando uma funcionalidade for validada e estiver dada como pronta, poderá seguir seu fluxo de trabalho normal, sendo feito o merge de sua branch com a `main`, como se a branch `desenvolvimento` não existisse. Desta forma apenas essa funcionalidade integrará a branch `main`, podendo ser validada no ambiente `Homologação` e chegar a `Produção`, sem as demais funcionalidades que ainda estão sendo testadas no ambiente `Desenvolvimento`. E ela pode se juntar a outras funcionalidades, como uma pequena correção que foi aplicada diretamente na branch `main`(ambientes `Homologação` e `Produção`), sem ter passado pela branch `desenvolvimento`.

{% mermaid() %}
gitGraph
    commit id: "0"
    branch feature-1 order: 2
    commit id: "1"
    commit id: "2"
    checkout main
    branch feature-2 order: 3
    commit id: "3"
    commit id: "4"
    checkout main
    branch desenvolvimento order: 1
    merge feature-1 id: "5"
    merge feature-2 id: "6"
    checkout feature-1
    commit id: "7"
    checkout desenvolvimento
    merge feature-1 id: "8"
    commit id: "REVERTE-8" type: REVERSE
    checkout feature-1
    commit id: "REVERTE-7" type: REVERSE
    checkout main
    branch fix-3 order: 4
    commit id: "9"
    checkout main
    merge fix-3 id: "10"
    merge feature-2 id: "11"
{% end %}

### Limpeza da branch

A funcionalidade foi testada na branch `desenvolvimento` e entregue na branch `main`, porém é possível observar que com o passar do tempo pode a surgir diferenças entre o código das branches `desenvolvimento` e `main`. Um caso foi a correção `fix-3`, que foi aplicada diretamente na `main`, sem passar pela `desenvolvimento`, e outro caso poderia ser a `feature-1`, se seu desenvolvimento for pausado ou cancelado. Isso é ruim, pois poderia gerar código que funciona na `desenvolvimento`, mas não na `main`.

Desta forma é recomendável fazer limpeza da branch `desenvolvimento`, que seria uma ressincronização com a branch `main` da onde ela surgiu. Ao fazer isso, serão removidas dela todas as funcionalidades que não chegaram na branch `main`, porém como essas funcionalidades ainda terão suas branches individuais, seus merges podem ser refeitos com a branch `desenvolvimento` se ainda for relevante e seu teste estiver ocorrendo. E se não, essa funcionalidade deixará de influenciar nos testes das demais.

Essa limpeza pode ser efetuada simplesmente recriando a branch, por exemplo:

```sh
git checkout -B desenvolvimento main
```

E ao unir a `feature-1` para testes na `desenvolvimento`, o histórico seria o seguinte:

{% mermaid() %}
gitGraph
    commit id: "0"
    branch feature-1 order: 2
    commit id: "1"
    commit id: "2"
    checkout main
    branch feature-2 order: 3
    commit id: "3"
    commit id: "4"
    checkout feature-1
    commit id: "7"
    commit id: "REVERTE-7" type: REVERSE
    checkout main
    branch fix-3 order: 4
    commit id: "9"
    checkout main
    merge feature-2 id: "10"
    merge fix-3 id: "11"
    branch desenvolvimento order: 1
    merge feature-1 id: "13"
{% end %}

Embora essa limpeza seja boa para manter as branches `desenvolvimento` e `main` semelhantes, evitando assim alguns problemas, uma frequência muito grande também pode dificultar os testes, uma vez que desativará as funcionalidades que estão em teste. Desta forma é necessário encontrar um equilíbrio, seja uma vez por dia ou semana, e isso pode mudar conforme o projeto. Outra opção é a criação de um "botão de manual", que poderia ser usado sempre que se achar necessário, e que pode até trabalhar em conjunto com algum agendamento.

## Como implementar?

Os comandos sugeridos anteriormente funcionam no repositório local. Para integrar com um repositório remoto é necessário algumas adaptações.

### Criando ou limpando a branch

Para criar ou limpar a branch `desenvolvimento` é necessário ter a branch `main` atualizada, criar a branch `desenvolvimento` e enviar para o servidor sobreescrevendo a atual. Isso pode ser feito com a seguinte sequência de comandos:

```sh
git fetch origin main
git checkout -B desenvolvimento origin/main
git push origin +desenvolvimento
```

### Merge de funcionalides para teste

Para adicionar uma funcionalidade na branch `desenvolvimento` é necessário ter as branches `desenvolvimento` e da funcionalidade desejada atualizada, após isso é necessário fazer o merge e enviar para o servidor. Isso pode ser feito com a seguinte sequência de comandos:

```sh
git fetch origin desenvolvimento feature-1
git checkout -B desenvolvimento origin/desenvolvimento
git merge --no-ff origin/feature-1
git push origin desenvolvimento
```

Caso alterações sejam feitas na branch da funcionalidade depois disso, é possível fazer um novo merge.

### Revertendo alterações

Caso alguma funcionalidade apresente erro, ou se deseja removê-la sem mexer nas demais, é possível reverter um merge na `desenvolvimento`. A forma para ter isso é ter a branch `desenvolvimento` atualiza e usar o próprio git para gerar um commit desfazendo as alterações do merge. Isso pode ser feito com a seguinte sequência de comandos informando o hash do commit de merge:

```sh
git fetch origin desenvolvimento
git checkout -B desenvolvimento origin/desenvolvimento
git revert -m 1 aa9ff52
```

Um ponto a se observar é que ao fazer um commit revertendo as alterações de um merge, não será mais possível fazer o merge dessa funcionalidade até a branch `desenvolvimento` ser limpa, uma vez que os commits da branch dessa funcionalidade já estão no histórico da `desenvolvimento`. Porém é possível reverter um commit que reverteu o merge, trazendo a funcionalidade de volta.

### Onde executar?

Uma forma de executar essas sequências de comandos é através de um script, onde quem desejar poderia executá-lo e passar qual a operação desejada, branch e afins.

Outra opção é utilizar alguma ferramenta de integração contínua (CI), assim bastaria executar um job passando as mesmas informações como parâmetro. Caso não tenha alguma ferramenta de CI e o deploy da aplicação for feito no [Kubernetes](https://kubernetes.io/pt-br/), é possível utilizar o [Tekton](https://tekton.dev/) para isso, ele irá executar o job usando o próprio Kubernetes para isso.

## Considerações

Não existe uma forma trivial de testar diferentes branches juntas, porém é possível fazer um fluxo com uma branch a parte para isso, sendo que essa branch não vai interferir no fluxo de trabalho anterior, ficando apenas como um passo opcional. Porém é necessário implementar algumas funcionalidades com sequências de comandos para isso.

O fluxo apresentado visa fazer um único deploy com todas as funcionalidades desejadas. Outra opção seria fazer um deploy separado para cada branch, dando um endereço diferente para acessá-los. Essa outra forma permitiria testar as funcionalidades de forma isolada, porém cada deploy consumiria recursos e poderia ter dificuldades caso seja necessário integrar esse novo deploy em algum serviço, como receber eventos ou mensagens de outros serviços.
