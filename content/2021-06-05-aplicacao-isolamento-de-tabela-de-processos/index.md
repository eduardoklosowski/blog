+++
title = "Isolamento de aplicações: Tabela de processos"

[taxonomies]
series = ["Isolamento de aplicações"]
tags = ["Sistema Operacional", "Processos"]
linguagens = []
+++

Todo serviço é um processo que está em execução no sistema operacional, e é possível extrair informações de um processo, ou até mesmo interagir com ele através de sinais, como o enviado para que um serviço releia suas configurações, sem precisar parar e iniciá-lo novamente para aplicar as alterações, ou para pedir que ele finalize (pare de executar). Um processo poderia se aproveitar desses mecanismos para obter informações, ou causar uma indisponibilidade.

## Obtendo informações

Uma forma de se obter informações através dos processos é simplesmente listando-os, onde seria possível visualizar serviços em execução, o que permitira identificar outras possibilidades de ataque. Isso pode ser feito utilizando o comando `ps ax`, que poderia listar que existe um servidor [Apache](https://httpd.apache.org/), por exemplo, onde o atacante poderia se focar em tentar explorar vulnerabilidades desse serviço específico, ou qualquer outro que esteja em execução.

Outro ponto que pode ser importante são os argumentos dos processos, que podem possuir alguma informação sensível. Muitas vezes senhas são passadas como argumento de um comando, como `mysql -uroot -psecreta`, que possui usuário (`root`) e senha (`secreta`) utilizados para conectar no banco de dados. Enquanto esse comando estiver em execução, ao listar os processos, seria possível obter essas informações.

## Interagindo com processos

Embora possa existir alguma segurança, ao executar os processos de cada aplicação com usuários diferentes, se isso não for feito, uma aplicação poderia pedir para o processo de outra aplicação ser finalizado. Mesmo se o processo for reiniciado logo em seguida por um supervisor (systemd, por exemplo), vai haver algum momento de indisponibilidade, principalmente se o serviço demora para iniciar. Isso derrubaria qualquer cliente que esteja conectado, e faria com que fosse necessário algum tempo até que os clientes possam se reconectar.

## Isolando processos

Uma forma de resolver esses problemas é impedindo com que um processo possa enxergar toda a tabela de processos do sistema operacional, permitindo visualizar apenas os processos relativos ao seu serviço (como processos filhos). Isso pode ser feito criando um espaço de nomes para os processos, onde qualquer processo dentro de um desses espaços veria apenas os processos do seu espaço, que inclusive podem possuir um número de identificador diferente ([pid](https://pt.wikipedia.org/wiki/Identificador_de_processo)), tendo um identificador dentro do espaço, porém mapeado para um identificador real que seria visível apenas pelos processos de fora desse espaço de nomes.

Esse espaço de nomes pode ser criado adicionando `unshare -fp --mount-proc` na frente do comando a ser executado, assim ao executar `unshare -fp --mount-proc /bin/bash` o processo do [Bash](http://tiswww.case.edu/php/chet/bash/bashtop.html) aberto não conseguiria ver os demais processos do sistema ao executar `ps ax`. E ao executar um processo em segundo plano, como `python3 -m http.server &`, ele seria listado no `ps ax` com um pid (exemplo `3`), porém ao executar `ps ax` em outro Bash, fora desse espaço de nomes, ele apareceria com outro pid (exemplo `13682`), onde dentro do espaço de nomes esse processo poderia ser finalizado com `kill 3`, mas fora desse espaço seria `kill 13682`.

## Considerações

A criação de espaços de nomes de processos (tabelas de processos) do sistema operacional reduz as possibilidades de uma aplicação interferir em outra, adicionando uma camada a mais de isolamento. Isso também impede que um processo de dentro de um espaço de nomes consiga obter informações de processos ou envie sinais para processos de outros espaços de nomes. Porém aqueles processos executados fora de um espaço de nomes definido terá acesso aos processos de todos os espaços de nomes, podendo listá-los, ver seus argumentos e lhes enviar sinais.
