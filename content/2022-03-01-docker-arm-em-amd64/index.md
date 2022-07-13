+++
title = "Criando e executando contêineres Docker ARM em arquitetura AMD64"

[taxonomies]
series = []
tags = ["Contêineres", "Docker", "ARM"]
linguagens = []
+++

Cada vez é mais comum encontrar ambientes com a arquitetura [ARM](https://pt.wikipedia.org/wiki/Arquitetura_ARM), seja um [Raspberry Pi](https://www.raspberrypi.org/) ou [servidores na nuvem](https://www.oracle.com/br/cloud/compute/arm/) buscando reduzir custos, ou até mesmo no [Apple M1](https://en.wikipedia.org/wiki/Apple_M1). Ela difere da arquitetura mais comumente encontrada nos computadores ([AMD64](https://pt.wikipedia.org/wiki/AMD64) também conhecido por x86_64). Essa diferença gera dificuldades para criar e executar contêineres de um ambiente em outro, dado que essas arquiteturas não possuem nativamente um modo de compatibilidade. Esse texto discutirá como executar programas para a arquitetura ARM em computadores AMD64, e como isso pode ser utilizado para gerar e executar imagens [Docker](https://www.docker.com/).

## Como executando programas de outra arquitetura?

Para se executar algo em qualquer arquitetura deve existir um programa com instruções que a CPU entenda. Operações similares podem ter instruções completamente diferentes em diferentes arquiteturas, e as arquiteturas podem ter desenhos diferentes de hardware, como variação na quantidade e tamanho dos registradores. Essas diferenças geram incompatibilidades e não permitem que um programa compilado para uma arquitetura seja executado em outra.

Porém, como existem operações similares, ou formas de se conseguir resultados equivalentes em diferentes arquiteturas, é possível adicionar uma camada que traduza as instruções de uma arquitetura para seu equivalente na arquitetura da CPU onde deseja-se executar o programa.

Um programa que faz essa tradução das instruções é o [QEMU](https://www.qemu.org/), que pode ser usado tanto para emular ou virtualizar tanto uma máquina inteira ([máquina virtual](https://pt.wikipedia.org/wiki/M%C3%A1quina_virtual)) quanto apenas um processo. Nesse caso, como serão executados apenas programas para [Linux](https://pt.wikipedia.org/wiki/Linux) trocando a arquitetura do processador, é possível emular apenas um processador ARM para esses programas, sem a necessidade de emular ou virtualizar uma máquina virtual inteira, o que incluiria até o sistema operacional.

Para instalar esse emular no [Debian](https://www.debian.org/) (ou derivados como [Ubuntu](https://ubuntu.com/)) existe o pacote [`qemu-user`](https://packages.debian.org/stable/qemu-user), porém ele é compilado de forma a carregar diversos arquivos `.so` (o equivalente as `.dll` do Windows), e como deseja-se executar contêineres, que fazem `chroot` como já expliquei na série {{ link_serie(name="Isolamento de aplicações") }}, deve-se optar pela opção que inclui as funções dos `.so` no próprio binário, oferecida pelo pacote [`qemu-user-static`](https://packages.debian.org/stable/qemu-user-static). Isso permite executar um programa compilado para ARM 32 bits chamando o emulador e passando o binário como argumento, exemplo `qemu-arm-static ./programa`, ou `qemu-aarch64-static ./programa` para ARM 64 bits.

Também é possível usar a interface do módulo `binfmt_misc` para informar ao kernel Linux, que quando for solicitado para ele executar um programa para ARM, isso deve ser feito através desse emulador. No Debian essa configuração é feita automaticamente pelo pacote do QEMU, bastando ter o pacote [`binfmt-support`](https://packages.debian.org/stable/binfmt-support) instalado (ele também pode ser instalado depois do QEMU). Para verificar essa configuração é possível executar o comando `update-binfmts --display qemu-arm` como `root`, ou ler o arquivo `/proc/sys/fs/binfmt_misc/qemu-arm` com qualquer usuário, e trocando `qemu-arm` para `qemu-aarch64` para testar a configuração de 64 bits. Segue um exemplo dessas configurações (observe o interpretador configurado, que é um link simbólico para o QEMU):

```txt
# update-binfmts --display qemu-arm
qemu-arm (enabled):
     package = qemu-user-static
        type = magic
      offset = 0
       magic = \x7f\x45\x4c\x46\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00
        mask = \xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff
 interpreter = /usr/libexec/qemu-binfmt/arm-binfmt-P
    detector =
```

```txt
$ cat /proc/sys/fs/binfmt_misc/qemu-arm
enabled
interpreter /usr/libexec/qemu-binfmt/arm-binfmt-P
flags: POCF
offset 0
magic 7f454c4601010100000000000000000002002800
mask ffffffffffffff00fffffffffffffffffeffffff
```

```txt
$ ls -la /usr/libexec/qemu-binfmt/arm-binfmt-P
lrwxrwxrwx 1 root root 25 set 29 07:14 /usr/libexec/qemu-binfmt/arm-binfmt-P -> ../../bin/qemu-arm-static
```

Assim ao executar o comando `apt install qemu-user-static binfmt-support` se torna possível executar um programa compilado para ARM de forma transparente, como se fosse nativo, exemplo `./programa`.

## Criando e executando contêineres Docker

Se a instalação e configuração do QEMU foi feita corretamente, já é possível usar contêineres ARM, bastando informar a arquitetura com o parâmetro `--platform linux/arm64` ao executar os comandos do Docker, exemplo `docker run --platform linux/arm64 -it --rm alpine`. Isso pode ser confirmado executado o comando `uname -m` dentro e fora do contêiner mostrando qual a arquitetura do sistema.

Caso ao executar algum comando do Docker ocorra um erro parecido com `standard_init_linux.go:228: exec user process caused: exec format error`, recomendo voltar e revisar a configuração do QEMU e `binfmt_misc`, visto que o Docker não conseguiu executar o programa dentro do contêiner.

Um detalhe a ser observado é que existe uma imagem chamada `alpine:latest` para AMD64 e outra para ARM, e ao fazer o pull de uma, ela vai retirar a tag da outra se existir no sistema, então é sempre bom verificar antes qual a imagem que existe localmente ou fazer pull para evitar misturar as imagens, o que causaria erros. A baixo um exemplo do `docker image ls` ao executar o pull tanto da imagem ARM quanto AMD64:

```txt
REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
alpine       <none>    8e1d7573f448   3 months ago   5.33MB
alpine       latest    c059bfaa849c   3 months ago   5.59MB
```

Seguindo o que foi visto até aqui, para se criar uma imagem para ARM pode-se utilizar o comando `docker build --platform linux/arm64 --pull -t <nome_imagem> .`, e trocando `linux/arm64` por `linux/amd64` criar a mesma imagem para AMD64, desde que no repositório de imagens ([Docker Hub](https://hub.docker.com/) por exemplo) existam as imagens usadas como base para ambas arquiteturas com o mesmo nome e tag. Também é válido observar que se as imagens geradas tiverem o mesmo nome, a última imagem gerada vai sobrescrever a tag da anterior, que se torna acessível apenas pelo ID.

Uma alternativa ao parâmetro `--platform` é a variável de ambiente `DOCKER_DEFAULT_PLATFORM`. A vantagem dessa opção é que ela pode ser definida em algum arquivo de configuração, como no `~/.bashrc`, adicionado `export DOCKER_DEFAULT_PLATFORM=linux/arm64`, e deixa de ser necessário informar o parâmetro `--platform` toda vez que o Docker for executado.

## Considerações

Embora as arquiteturas AMD64 e ARM não sejam compatíveis é possível utilizar o QEMU para fazer a execução de programas ARM em CPUs da arquitetura AMD64. Porém, como isso é feito por software, e não pelo hardware, pode ocorrer problemas de desempenho, o qual ainda deve ser verificado.

Dado que o sistema consegue executar programas ARM de forma transparente, isso se reflete no Docker, permitindo tanto criar imagens para ARM, quanto executá-las, bastando observar a limitação da lincagem dinâmica com arquivos `.so` devido ao `chroot` que ocorre.
