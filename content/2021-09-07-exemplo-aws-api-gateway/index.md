+++
title = "Exemplo de AWS API Gateway com Lambda pelo Terraform"

[taxonomies]
series = []
tags = ["Exemplo", "AWS"]
linguagens = ["Terraform"]
+++

Estou estudando sobre a [AWS](https://aws.amazon.com/pt/) e algumas ferramentas. Para praticar o aprendido resolvi montar de exemplo uma [API Rest](https://www.restapitutorial.com/) utilizando o [API Gateway](https://docs.aws.amazon.com/apigateway/) rodando o código em [lambdas](https://docs.aws.amazon.com/lambda/), e para criar o ambiente optei pelo [Terraform](https://www.terraform.io/) conectando no [LocalStack](https://localstack.cloud/) (já que esse pode rodar localmente e não exige uma conta na AWS). Nesse texto descreverei o processo e quais tecnologias utilizei.

Primeiramente, para organizar o que precisaria implementar na [API Rest](https://www.restapitutorial.com/) utilizei o [OpenAPI](https://www.openapis.org/), que já serve de documentação da API também. O resultado [foi um YAML](https://github.com/eduardoklosowski/exemplo-aws-api-gateway/blob/main/openapi.yml) que pode ser visualizado em algum editor que segue o padrão do OpenAPI, como o [Swagger Editor](https://editor.swagger.io/) (que atualmente apresenta alguns erros por não implementar ainda a versão utilizada da especificação).

Com a documentação da API pronta, o próximo passo foi subir o ambiente de nuvem, que optei pelo [LocalStack](https://localstack.cloud/) que eu poderia rodar no meu próprio computador. Porém a versão gratuita do LocalStack não oferece suporte ao [RDS](https://docs.aws.amazon.com/rds/) para criar o banco de dados, então resolvi rodar o [PostgreSQL](https://www.postgresql.org/) por fora do ambiente de nuvem simulado pelo LocalStack. Para rodar tanto o PostgreSQL quanto o LocalStack optei por executá-los através de contêineres gerenciados pelo [Docker Compose](https://docs.docker.com/compose/), que também é feito através de um [YAML](https://github.com/eduardoklosowski/exemplo-aws-api-gateway/blob/main/docker-compose.yml).

Com o LocalStack rodando é necessário uma forma de interagir com ele, uma delas é através do [AWS CLI](https://docs.aws.amazon.com/cli/), porém optei pelo [LocalStack AWS CLI](https://github.com/localstack/awscli-local) que já configura os parâmetros necessários para se conectar no LocalStack em vez da AWS. Sua instalação pode ser feita através do [pip](https://pip.pypa.io/en/stable/) com o pacote [awscli-local](https://pypi.org/project/awscli-local/).

Para processar as requisições optei por utilizar [lambdas](https://docs.aws.amazon.com/lambda/), que nada mais são do que um serviço da AWS que permite a execução de funções sem precisar se preocupar com o servidor (máquina virtual) onde rodarão. Visando ter um código o mais simples possível, utilizei diretamente o driver do PostgreSQL para Python ([psycopg2](https://www.psycopg.org/)), onde cada endereço da API seria [respondido pela execução de uma função distinta](https://github.com/eduardoklosowski/exemplo-aws-api-gateway/blob/main/tarefa.py) (O readme do projeto detalha mais sobre os [comandos para interagir com os lambdas](https://github.com/eduardoklosowski/exemplo-aws-api-gateway#lambdas)).

Com os lambdas prontos, é necessário disponibilizar sua execução através de endereços HTTP, que é justamente o que o [API Gateway](https://docs.aws.amazon.com/apigateway/) faz. Nesse caso é necessário criar uma API, os caminhos dessa API e dizer quais métodos estão disponíveis, [associando-os aos lambdas](https://github.com/eduardoklosowski/exemplo-aws-api-gateway#api-gateway).

Porém eu gostaria de utilizar também o [Terraform](https://www.terraform.io/) para criar esses recursos no LocalStack, então optei por recomeçar a configuração do zero. Para [configurar o ambiente pelo Terraform](https://github.com/eduardoklosowski/exemplo-aws-api-gateway#deploy-com-terraform) basta criar um arquivo que descreva os [recursos desejados](https://github.com/eduardoklosowski/exemplo-aws-api-gateway#deploy-com-terraform), porém por questão de organização optei por [dividir em módulos](https://github.com/eduardoklosowski/exemplo-aws-api-gateway/tree/main/terraform) e com o arquivo de estado do Terraform em um [bucket S3](https://docs.aws.amazon.com/s3/) simulando um ambiente que permite sua execução em computadores distintos.

Finalmente ao executar o Terraform obtive uma URL como `http://localhost:4566/restapis/mea14qi3dw/main/_user_request_` onde pude acessar a API a partir dela, o qual realizei testes usando o [HTTPie](https://httpie.io/) devido a sua facilidade de uso, ou através da interface disponibilizada pelo Swagger Editor que já é integrado na documentação.

Caso deseje visualizar o processo de deploy com Terraform, segue um vídeo do procedimento sendo executado:

{{ asciinema(id="433410") }}

O repositório com o código utilizado está no meu [GitHub](https://github.com/eduardoklosowski/exemplo-aws-api-gateway).
