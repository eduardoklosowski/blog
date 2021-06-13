+++
title = "Isolamento de aplicações: Pilha de rede"

[taxonomies]
series = ["Isolamento de aplicações"]
tags = ["Sistema Operacional", "Redes"]
linguagens = []
+++

Uma das formas de comunicação mais comum entre processos é através da rede, o que permite tanto a comunicação de processos no mesmo computador, quanto em diferentes computadores. A comunicação pela rede normalmente utiliza portas [TCP](https://pt.wikipedia.org/wiki/Transmission_Control_Protocol) ou [UDP](https://pt.wikipedia.org/wiki/User_Datagram_Protocol), porém algumas aplicações podem querer utilizar a mesma porta de rede, como a porta 80 TCP que é a porta padrão para serviços [HTTP](https://pt.wikipedia.org/wiki/Hypertext_Transfer_Protocol), ou 443 TCP para [HTTPS](https://pt.wikipedia.org/wiki/Hyper_Text_Transfer_Protocol_Secure), o que geraria conflitos.

## Soluções possíveis

Existem algumas formas de lidar com essa questão:

### Definindo o número da porta

A solução mais simples para o caso de dois processos quererem utilizar o mesmo número de porta é alterar a porta utilizada por algum dos processos. Isso normalmente envolve alterar a configuração da aplicação, e torna obrigatório informar o endereço da porta para acessar o serviço, uma vez que ele não se encontra mais em sua porta padrão. Um exemplo é `http://127.0.0.1:8080/`, onde esse endereço informa para conectar na porta 8080 em vez da porta 80 (padrão). Porém algumas aplicações não foram feitas pensando na possibilidade de executar em outra porta, e mesmo se configuradas para tal, podem não funcionar corretamente, como um sistema web, onde são utilizados endereços fixos que assumem que o serviço esteja rodando na porta padrão e acabam redirecionando o usuário para ela.

Para os sistemas que puderem ser executados em outras portas, essa configuração variará conforme o programa. Mas para verificar quais portas estão sendo utilizadas é possível executar o comando `ss -nltup` que lista todas as portas que estão no modo de escuta (aguardando uma conexão no caso do TCP, ou esperando receber dados no caso do UDP) assim como o processo que está utilizando cada porta, facilitando tanto encontrar um número de porta disponível, quanto identificar qual outra aplicação está utilizando a porta desejada. Porém com essa configuração, além do endereço do servidor, também será necessário lembrar em qual porta que o serviço está rodando para conseguir acessá-lo.

### Definindo outro endereço IP

Embora muitas vezes se pense em um serviço ouvindo apenas uma porta (ou mais de uma porta, dependendo da aplicação), para o sistema operacional cada processo ouve uma porta de um endereço de rede. Desta forma é possível que dois serviços utilizem a mesma porta TCP ou UDP, porém desde que em endereços de rede diferentes, sendo necessário configurar um segundo endereço no computador (adicionando um novo endereço na interface no caso do IPv6, ou criando um *alias* para a interface no caso do IPv4), ou configurar para um serviço ser disponibilizado para o endereço de uma interface de rede, e outro serviço para o endereço de outra interface de rede.

Com a configuração dos endereços de rede feita, na configuração da aplicação é necessário informar em qual endereço de rede e porta que ela deverá aguardar conexões, e isso novamente varia conforme o programa. Porém quando estiver em execução, o mesmo também pode ser visto pelo comando `ss -nltup`.

O exemplo a baixo mostra um computador com dois servidores de nomes ([DNS](https://pt.wikipedia.org/wiki/Sistema_de_Nomes_de_Dom%C3%ADnio)) em execução. O primeiro ouvindo no IP 127.0.0.1 e porta 53, tanto TCP, quanto UDP. Esse serviço, por utilizar o endereço de *loopback*, é acessível apenas da máquina local. O segundo servidor de nomes ouve no IP 192.168.122.1 e porta 53, também nos protocolos TCP e UDP. Nesse caso, o serviço está disponível para uma rede de [máquinas virtuais](https://pt.wikipedia.org/wiki/M%C3%A1quina_virtual) do [libvirt](https://libvirt.org/). Em ambos os casos, esse serviço está atribuído a um endereço de rede específico, diferente do [SSH](https://pt.wikipedia.org/wiki/Secure_Shell) que ouve em qualquer endereço de rede (0.0.0.0 no caso de IPv4 e [::] no caso de IPv6) na porta 22 apenas TCP.

```txt
Netid     State       Recv-Q      Send-Q            Local Address:Port            Peer Address:Port
udp       UNCONN      0           0                     127.0.0.1:53                   0.0.0.0:*         users:(("dnsmasq",pid=994,fd=4))
udp       UNCONN      0           0                 192.168.122.1:53                   0.0.0.0:*         users:(("dnsmasq",pid=838,fd=5))
tcp       LISTEN      0           32                    127.0.0.1:53                   0.0.0.0:*         users:(("dnsmasq",pid=994,fd=5))
tcp       LISTEN      0           32                192.168.122.1:53                   0.0.0.0:*         users:(("dnsmasq",pid=838,fd=6))
tcp       LISTEN      0           128                     0.0.0.0:22                   0.0.0.0:*         users:(("sshd",pid=695,fd=3))
tcp       LISTEN      0           128                        [::]:22                      [::]:*         users:(("sshd",pid=695,fd=4))
```

### Outra pilha de rede

Outra opção é utilizar instâncias diferentes da pilha de rede do sistema operacional para cada aplicação, onde cada instância teria suas interfaces e endereços de rede, e assim uma não conflitaria com a outra. Uma forma de fazer isso é através do espaço de nomes, e informado que tal processo será executado dentro de tal espaço.

Todo o controle do espaço de nomes (criação, configuração e execução de processos) pode ser feito através do comando `ip` que faz parte do [iproute2](https://wiki.linuxfoundation.org/networking/iproute2), que substitui o antigo [net-tools](https://sourceforge.net/projects/net-tools/). Nesse exemplo ele será utilizado para criar um espaço de nomes (`app1`), criar duas interfaces virtuais conectadas entre si (`veth0` e `veth1`), atribuir uma interface ao espaço de nomes da aplicação (`veth1`), configurado os endereços de rede, e por fim, executado um processo dentro desse espaço:

```sh
# Cria espaço de nomes app1
ip netns add app1

# Cria interfaces de redes virtuais
ip link add veth0 type veth peer name veth1

# Atribui uma interface de rede para a aplicação
ip link set veth1 netns app1

# Define endereços de rede das interfaces
ip addr add 10.1.1.1/30 dev veth0
ip netns exec app1 ip addr add 10.1.1.2/30 dev veth1

# Liga as interfaces
ip link set veth0 up
ip netns exec app1 ip link set veth1 up
ip netns exec app1 ip link set lo up

# Configura gateway para a interface da aplicação
ip netns exec app1 ip route add default via 10.1.1.1

# Executa processo do Bash dentro do espaço de nomes
ip netns exec app1 bash
```

Esse último comando abrirá um terminal do [Bash](http://tiswww.case.edu/php/chet/bash/bashtop.html) que terá acesso à outra pilha de rede, sendo possível executar comandos como `ping 10.1.1.1` para verificar a comunicação com a pilha de rede que está rodando fora desse espaço de nomes. O Bash também pode ser substituído por outro processo, como o [NGINX](https://nginx.org/) (exemplo `ip netns exec app1 nginx -g 'daemon off;'`), e que assim poderia ser acessado pelo navegador através do endereço `http://10.1.1.2/`.

Para que esse serviço possa ser acessado de outro computador, ainda é necessário fazer algumas configurações adicionais, como configurar a rota para a rede das interfaces virtuais nos dispositivos de rede, ou alguma tradução de endereços ([NAT](https://pt.wikipedia.org/wiki/Network_address_translation)) ou porta ([PAT](https://pt.wikipedia.org/wiki/Port_address_translation)), uma vez que a pilha de rede padrão funcionará como um [roteador](https://pt.wikipedia.org/wiki/Roteador) ou [firewall](https://pt.wikipedia.org/wiki/Firewall) para a segunda pilha criada desta forma.

## Considerações

A criação de espaços de nomes de rede pode ser bastante interessante para isolar aplicações para que elas não conflitem pelo uso de alguma porta, mas também pode ser utilizada para isolar a comunicação entre processos, de tal forma que a rede entre eles não seja acessível por terceiros. Um exemplo que isola a comunicação entre os processos em redes diferentes é o [OpenStack](https://www.openstack.org/), que é uma solução para a criação de nuvens privadas (criar um ambiente de nuvem dentro de seu próprio [*data center*](https://pt.wikipedia.org/wiki/Centro_de_processamento_de_dados)), onde alguns desses comandos do `ip netns` aparecem no [guia para soluções de problemas de rede](https://docs.openstack.org/operations-guide/ops-network-troubleshooting.html#dealing-with-network-namespaces), permitindo assim executar comando com acessos as redes virtuais da nuvem, o qual não seria possível normalmente.
