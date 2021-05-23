+++
title = "Liberar acesso ao servidor SSH pelas chaves do GitHub"

[taxonomies]
series = []
tags = ["Dicas", "GitHub"]
linguagens = []
+++

Uma das formas mais utilizadas para acessar servidores GNU/Linux é através do [SSH](https://pt.wikipedia.org/wiki/Secure_Shell). Esse acesso pode ocorrer através de usuário e senha ou de um par de chaves criptográfica, normalmente [RSA](https://pt.wikipedia.org/wiki/RSA_(sistema_criptogr%C3%A1fico)) ou mais recente [Ed25519](https://pt.wikipedia.org/wiki/ECDSA), que são chaves assimétricas, onde a chave pública é copiada para o servidor e a privada fica no cliente que está pedindo acesso. Esse processo é o mesmo que ocorre no GitHub para permitir o acesso aos repositórios através de SSH, e é possível se aproveitar disso.

Caso tenha alguma dúvida para criar chaves, ou mesmo queira verificar como configurar o cliente SSH, recomendo dar uma olhada no meu texto sobre [configuração do Git](@/2021-03-22-configuracao-basica-do-git-e-github/index.md).

## Permitindo acesso através da chave

Primeiramente, para permitir o acesso a um servidor por chave criptográfica, basta adicionar a chave pública no arquivo `~/.ssh/authorized_keys`, onde `~` é a home do usuário no servidor ao qual deseja-se permitir o acesso remoto. Desta forma, basta conseguir uma cópia da chave pública para permitir o acesso. Lembrando que o serviço do SSH deve estar em execução nesse servidor (para Debian e derivados basta instalar o pacote `openssh-server`).

## Acessando a chave pública no GitHub

Como a chave pública não é uma informação sensível, e pode ser divulgada, o GitHub lista as chaves públicas cadastradas dos usuários ao adicionar `.keys` ao final do link do perfil. Exemplo: `https://github.com/eduardoklosowski.keys`. Assim ao acessar essa URL será listada todas as chaves públicas cadastradas para a conta, em vez de mostrar o perfil do usuário. Desta forma, basta adicionar essas chaves ao final do arquivo `~/.ssh/authorized_keys` e o dono dessa conta já poderá acessar o servidor.

Esse processo também poderia ser feito através da linha de comando, não sendo necessário copiar e colar as chaves, bastando executar um dos comandos abaixo (de acordo com a ferramenta que estiver disponível no servidor):

```sh
curl https://github.com/eduardoklosowski.keys >> ~/.ssh/authorized_keys
# Ou
wget -qO - https://github.com/eduardoklosowski.keys >> ~/.ssh/authorized_keys
```

## Considerações

Muitos desenvolvedores possuem conta no GitHub, e adicionaram suas chaves públicas a sua conta. Então fazer esse processo permite liberar o acesso a um servidor de forma fácil e segura (desde que o dono da conta mantenha sua chave privada de forma segura). Uma aplicação bastante interessante disso é na criação de servidores para [pair programming](https://pt.wikipedia.org/wiki/Programa%C3%A7%C3%A3o_pareada), onde um servidor pode ser criado e as pessoas que forem programar podem compartilhar o terminal através do [tmux](https://tmux.github.io/), sendo necessário se conhecer apenas o nome de usuário do GitHub, em vez de criar uma senha e compartilhá-la, ou pedir e aguardar a outra pessoa enviar sua chave pública.
