#!/usr/bin/env ruby
# frozen_string_literal: true

require 'irb'
require 'otr-activerecord'
require_relative '../starbus-api'

## Esse arquivo permite que rode a aplicacao no console irb.

# Carrega as configuracoes do Active Record
OTR::ActiveRecord.configure_from_file! 'config/database.yml'

# Starta o irb
IRB.start
