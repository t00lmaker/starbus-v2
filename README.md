# StarBus API - 0.0.1
[![Build Status](https://travis-ci.org/t00lmaker/starbus-v2.svg?branch=master)](https://travis-ci.org/t00lmaker/starbus-v2)
[![Coverage Status](https://coveralls.io/repos/github/t00lmaker/starbus-v2/badge.svg?branch=travisci)](https://coveralls.io/github/t00lmaker/starbus-v2?branch=travisci)

Uma plataforma de crowdsourcing para usuário de transporte público de Teresina.

### Organização

StarBus é formada por três componentes principais:

#### Apps
  Aplicativos iOs e Android em que usuários utilizar em seus smartphones em que
  os usuários de transporte publico pode interagir entre si e com a estrutura
  de transport público local.  

#### Dashboard
  Dados públicos sobre o transporte público local construidos pela utilização da
  dos app, que são mostrados de forma a gerar informação relevante para a sociedade.

#### API
  Core do Starbus que deve pode ser acessada via App, Dashboard e por outras aplições de
  outros produtores de software. Oferece as informações que alimentam a plataforma.  

Esse repositorio guarda a api e a landpage do projeto.

### O que você pode encontrar nesse repositorio ?

 * Uma API implementada com o framwork [Grape](http://www.ruby-grape.org)
 * Teste de uma api utilizando Rspec e [Airborne](https://github.com/brooklynDev/airborne)
 * Uma API e uma aplicação rodando no mesmo servidor, utilizando dois frameworks diferentes Grape e Sinatra.


 ### Comandos ulteis

Avalia o codigo e corrige o que pode ser corrigido.
bundle exec rubocop -a -x

Coveralls report
bundle exec coveralls report

Setup banco em test
rake db:setup RAILS_ENV=test

Seeds banco de dados em test.
rake db:seed RAILS_ENV=test

Monitorar arquivos 
bundle exec guard -d  


