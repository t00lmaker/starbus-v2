# StarBus API - 0.0.1
[![Build Status](https://travis-ci.org/t00lmaker/starbus-v2.svg?branch=master)](https://travis-ci.org/t00lmaker/starbus-v2)
[![Coverage Status](https://coveralls.io/repos/github/t00lmaker/starbus-v2/badge.svg?branch=master)](https://coveralls.io/github/t00lmaker/starbus-v2?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/a99a88d28ad37a79dbf6/maintainability)](https://codeclimate.com/github/codeclimate/codeclimate/maintainability)

Uma plataforma de crowdsourcing para usuário de transporte público de Teresina. Aqui podem ser centralizadas as informacoes sobre o 
transporte público da capital. Desenvolvedores de aplicativo podem utilizar nossa plataforma como fonte de dados e podem compartilhar
a visão de seus usuário sobre o transporte público da capital. 

### API

Veja a documentacão da nossa API [aqui](https://documenter.getpostman.com/view/593922/Szf52UVe). 

#### Apps
  Aplicativos iOs e Android em que usuários utilizar em seus smartphones em que
  os usuários de transporte publico pode interagir entre si e com a estrutura
  de transport público local.  

#### Dashboard
  Dados públicos sobre o transporte público local construidos pela utilizacão da
  dos app, que são mostrados de forma a gerar informacão relevante para a sociedade.

#### API
  Core do Starbus que deve pode ser acessada via App, Dashboard e por outras aplicoes de
  outros produtores de software. Oferece as informacoes que alimentam a plataforma.  

Esse repositorio guarda a api e a landpage do projeto.

### Para Devs - O que você pode encontrar nesse repositorio ?

 * Uma API implementada com o framwork [Grape](http://www.ruby-grape.org)
 * Teste de uma api utilizando Rspec e [Airborne](https://github.com/brooklynDev/airborne)
 * Um fluxo de CI/CD usando [Travis](https://travis-ci.org/) CI que faz deploy automatizados na plataforma [Heroku](https://www.heroku.com/).  

### Para Devs - Comandos ulteis


#### Relatório de cobertura de testes
```
bundle exec coveralls report
```
#### Setup banco em test
```
rake db:setup RAILS_ENV=test
```
#### Seeds banco de dados em test
```
rake db:seed RAILS_ENV=test
```
#### Monitora arquivo e salvos roda os testes
```
bundle exec guard -d  
```
#### Avalia o codigo e corrige o que pode ser corrigido
```
bundle exec rubocop -a -x
```
