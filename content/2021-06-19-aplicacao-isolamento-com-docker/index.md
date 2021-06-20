+++
title = "Isolamento de aplicações: Docker"

[taxonomies]
series = ["Isolamento de aplicações"]
tags = ["Sistema Operacional", "Contêineres", "Docker"]
linguagens = []
+++

Nos textos anteriores dessa série vimos como isolar uma aplicação nos contextos de sistema de arquivos, tabela de processos e pilha de rede. Porém isso pode se tornar um pouco complexo para ser gerenciado na mão, precisando executar algo como `ip netns exec app1 unshare -fp --mount-proc chroot /media/sistema bash` apenas para rodar um terminal dentro de determinados espaços de nomes, sem contar toda a configuração necessária para isso. Mas existem ferramentas que facilitam criar e executar aplicações dentre de espaço de nomes, o que hoje são conhecidas como contêineres.

## O que é um contêiner

Contêiner é uma forma padronizada de entregar e executar uma aplicação, utilizando-se dos conceitos de espaço de nomes para criar um ambiente isolado para rodar a aplicação, dependendo o mínimo possível do sistema operacional do computador onde será executado, e para isso deve providenciar todos os arquivos e bibliotecas necessários para sua execução, o que normalmente é chamado de imagem.

A seguir serão discutidos como os conceitos visto até então de isolamento de aplicações são aplicados no [Docker](https://www.docker.com/).

### Isolamento de sistema de arquivos

No texto sobre [isolamento de sistema de arquivos](@/2021-05-29-aplicacao-isolamento-de-sistema-de-arquivos/index.md) foi apresentado o uso do `debootstrap` para criar um diretório com a estrutura de um sistema operacional e o `chroot` para utilizá-lo como se fosse a raiz do sistema.

No Docker também é necessário uma estrutura de sistema de arquivos, contendo as dependências da aplicação, como bibliotecas e ferramentas. Olhando o [repositório da imagem oficial do Debian para o Docker](https://github.com/debuerreotype/docker-debian-artifacts/tree/dist-amd64/buster), pode-se observar a existência de um arquivo `Dockerfile` que é o responsável por dizer como construir a imagem desse contêiner, e que utiliza um arquivo `rootfs.tar.xz`, ou seja, um arquivo que contem todo o sistema de arquivos necessário para o contêiner.

É possível repetir esse processo com o sistema criado pelo `debootstrap`, para isso basta navegar até o diretório onde ele foi criado e gerar um arquivo `tar` com seu conteúdo, compactando-o ou não.

```sh
cd /media/sistema
tar -cvf ../rootfs.tar .
```

Isso gerará um arquivo `rootfs.tar.xz` que deve ser colocado em um diretório junto com o arquivo `Dockerfile` a baixo:

```dockerfile
FROM scratch
ADD rootfs.tar /
CMD ["bash"]
```

Com esses dois arquivos prontos, para gerar a imagem do contêiner basta executar `docker build -t sistema .`, que gerará uma imagem com o nome de `sistema`:

```txt
Sending build context to Docker daemon  317.4MB
Step 1/3 : FROM scratch
 --->
Step 2/3 : ADD rootfs.tar /
 ---> e8ca0bcee43d
Step 3/3 : CMD ["bash"]
 ---> Running in 84d7a3d758f9
Removing intermediate container 84d7a3d758f9
 ---> 94cdf37927fa
Successfully built 94cdf37927fa
Successfully tagged sistema:latest
```

Com a imagem pronta, para iniciar um contêiner basta executar `docker run -it --rm sistema bash`. A principal vantagem dessa abordagem é a possibilidade de abrir um outro terminal, executar o mesmo comando e ter outro ambiente isolado, o qual pode ser repetido diversas vezes. Ou como será mostrado mais para frente, executar outro processo dentro do mesmo espaço de nomes.

Vale observar também como funciona o sistema de arquivos nas imagens dos contêineres. Sempre existe uma imagem base, que nesse caso foi a `scratch` que é um nome reservado para uma imagem em branco (sem nada dentro), e a partir dela cada comando do `Dockerfile` criou outra camada em cima dela. Imagine como se a imagem base fosse um desenho em uma folha de papel, e as camadas posteriores fossem um plástico transparente colocado por cima desse desenho, seria possível ver o desenho e desenhar em cima dele, porém tudo que for desenhado estaria no plástico e não no papel de baixo, e ao colocar outra camada, seria possível ver o plástico em baixo, e o papel ao fundo, mas tudo que fosse desenhado agora estaria no novo plástico colocado. Essa é a ideia de [*copy-on-write*](https://pt.wikipedia.org/wiki/C%C3%B3pia_em_grava%C3%A7%C3%A3o) (COW), onde é possível ler o que estiver nas camadas mais a baixo, desde que elas não forem sobrescritas por algo nas camadas superiores, mas a gravação sempre ocorre na última camada.

E embora funcional, como o `debootstrap` gera um sistema operacional para ser instalado em um computador, ele adiciona diversos arquivos que não são necessários para o contêiner. Nesse exemplo o `rootfs.tar` gerado pelo `debootstrap` tem 302,7MiB contra 113,7MiB do mesmo arquivo no repositório da imagem Debian quando descompactado, e 59,4MiB contra 28,7MiB quando se compara os dois arquivos compactados (nesse caso o arquivo foi compactado com `xz -9 -e rootfs.tar`, a forma mais otimizada possível). Desta forma é recomendável utilizar a imagem oficial, que além de poupar o trabalho, é mais otimizada em relação ao espaço.

## Isolamento de tabela de processos

Além do isolamento de sistema de arquivos, o Docker também oferece o [isolamento da tabela de processos](@/2021-06-05-aplicacao-isolamento-de-tabela-de-processos/index.md). Para visualizar isso é possível executar um processo como o [Nginx](https://nginx.org/) dentro do contêiner com `nginx -g 'daemon off;'` (depois de instalado com `apt install nginx`, por exemplo), e em outro terminal executar `docker exec -it gifted_darwin bash` para abrir um Bash dentro desse mesmo contêiner, e assim ser possível verificar os processos em execução dentro desse contêiner com `ps aux`:

```txt
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   3988  3240 pts/0    Ss   11:28   0:00 bash
root       825  0.0  0.0  67700 12572 pts/0    S+   11:30   0:00 nginx: master process nginx -g daemon off;
www-data   826  0.0  0.0  68084  3444 pts/0    S+   11:30   0:00 nginx: worker process
www-data   827  0.0  0.0  68084  3444 pts/0    S+   11:30   0:00 nginx: worker process
www-data   828  0.0  0.0  68084  3444 pts/0    S+   11:30   0:00 nginx: worker process
www-data   829  0.0  0.0  68084  3444 pts/0    S+   11:30   0:00 nginx: worker process
www-data   830  0.0  0.0  68084  3444 pts/0    S+   11:30   0:00 nginx: worker process
www-data   831  0.0  0.0  68084  3444 pts/0    S+   11:30   0:00 nginx: worker process
www-data   832  0.0  0.0  68084  3444 pts/0    S+   11:30   0:00 nginx: worker process
www-data   833  0.0  0.0  68084  3444 pts/0    S+   11:30   0:00 nginx: worker process
root       834  0.2  0.0   3868  3268 pts/1    Ss   11:32   0:00 bash
root       840  0.0  0.0   7640  2692 pts/1    R+   11:32   0:00 ps aux
```

Porém ao executar um `ps aux | grep nginx` fora do contêiner, os mesmos processos são visualizados, porém com os seus números de processos reais, uma vez que o Nginx está executando de verdade no kernel da máquina física.

```txt
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root     14505  0.0  0.0  67700 12572 pts/0    S+   08:30   0:00 nginx: master process nginx -g daemon off;
www-data 14506  0.0  0.0  68084  3444 pts/0    S+   08:30   0:00 nginx: worker process
www-data 14507  0.0  0.0  68084  3444 pts/0    S+   08:30   0:00 nginx: worker process
www-data 14508  0.0  0.0  68084  3444 pts/0    S+   08:30   0:00 nginx: worker process
www-data 14509  0.0  0.0  68084  3444 pts/0    S+   08:30   0:00 nginx: worker process
www-data 14510  0.0  0.0  68084  3444 pts/0    S+   08:30   0:00 nginx: worker process
www-data 14511  0.0  0.0  68084  3444 pts/0    S+   08:30   0:00 nginx: worker process
www-data 14512  0.0  0.0  68084  3444 pts/0    S+   08:30   0:00 nginx: worker process
www-data 14513  0.0  0.0  68084  3444 pts/0    S+   08:30   0:00 nginx: worker process
```

### Isolamento de pilha de rede

Em relação ao [isolamento da pilha de rede](@/2021-06-12-aplicacao-isolamento-de-pilha-de-rede/index.md), o Docker apresenta algumas opções, como não permitir acesso a rede (`null`), utilizar a mesma pilha do sistema (`host`), ou utilizar uma rede virtual semelhante a feita anteriormente de forma manual (`bridge`). Por padrão todos os contêineres são executados dentro da rede `bridge`, porém é possível criar redes distintas para alguns contêineres também.

As redes disponíveis podem ser verificadas com o comando `docker network ls`:

```txt
NETWORK ID     NAME                DRIVER    SCOPE
1e363194a6f7   bridge              bridge    local
44ff21ce424a   host                host      local
e69eb4f8b6e8   none                null      local
```

Fora do contêiner é possível verificar os endereços que o computador tem em cada rede através do comando `ip addr`, procurando as interfaces de rede começando com `docker` seguida de algum número. Exemplo:

```txt
6: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:05:6f:f2:38 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:5ff:fe6f:f238/64 scope link
       valid_lft forever preferred_lft forever
```

Ao executar o mesmo comando dentro do contêiner são exibidos seus endereços da pilha de rede:

```txt
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
11: eth0@if12: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```

Porém caso queira não criar uma nova pilha de rede para o contêiner, é possível adicionar o parâmetro `--network host` ao comando `docker run` (exemplo `docker run -it --rm --network host sistema bash`). Assim ao executar `ip addr` serão exibidas as mesmas interfaces de rede da máquina, não aplicando essa técnica de isolamento.

### Outros isolamentos

Ainda existem outros tipos de isolamento de espaço de nomes aplicados pelo Docker, e eles podem ser listados através do comando `ls -la /proc/self/ns` que quando executado dentro do contêiner, lista exatamente os mesmos espaços de nomes que quando executado fora do contêiner informando o número do processo, como `ls -la /proc/15277/ns`:

```txt
total 0
dr-x--x--x 2 root root 0 jun 13 08:37 .
dr-xr-xr-x 9 root root 0 jun 13 08:37 ..
lrwxrwxrwx 1 root root 0 jun 13 08:40 cgroup -> 'cgroup:[4026531835]'
lrwxrwxrwx 1 root root 0 jun 13 08:40 ipc -> 'ipc:[4026532573]'
lrwxrwxrwx 1 root root 0 jun 13 08:40 mnt -> 'mnt:[4026532571]'
lrwxrwxrwx 1 root root 0 jun 13 08:37 net -> 'net:[4026532576]'
lrwxrwxrwx 1 root root 0 jun 13 08:40 pid -> 'pid:[4026532574]'
lrwxrwxrwx 1 root root 0 jun 13 08:43 pid_for_children -> 'pid:[4026532574]'
lrwxrwxrwx 1 root root 0 jun 13 08:40 user -> 'user:[4026531837]'
lrwxrwxrwx 1 root root 0 jun 13 08:40 uts -> 'uts:[4026532572]'
```

## Considerações

O Docker é uma ferramenta que torna muito mais prático a execução de processos dentro de espaços de nome do kernel, além de automatizar muito do trabalho de suas configurações. Também apresenta alguns diferenciais do processo manual demonstrado, como as camadas aplicadas no sistema de arquivos, o que permite que várias imagens compartilhem algumas camadas, e que mais de um contêiner possa ser executado a partir do mesmo sistema de arquivos, onde cada contêiner teria sua última camada de forma particular.

Com o processo manual, também fica mais evidente do motivo do Docker no Windows rodar dentro de um ambiente virtualizado, uma vez que é necessário um kernel Linux em execução, visto que os programas do contêiner normalmente esperam se comunicar com um kernel Linux. Embora também exista alguns [contêineres específicos para Windows](https://hub.docker.com/_/microsoft-windows), e que neste caso específico exigem o kernel do Windows. Assim como as arquiteturas, um contêiner feito para x86_64 não vai funcionar em um hardware ARM, a menos que uma virtualização de espaço de usuário, como a oferecida pelo [QEMU](https://www.qemu.org/), seja utilizada.
