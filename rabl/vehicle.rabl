# frozen_string_literal: true

object @vehicle
attributes :code, :time, :lat, :long, :last_lat, :last_long
child :reputation do |ele|
  node(:mov) { ele.avg('MOVIMENTACAO') }
  node(:est) { ele.avg('ESTADO') }
  node(:seg) { ele.avg('SEGURANCA') }
  node(:con) { ele.avg('CONFORTO') }
  node(:ace) { ele.avg('ACESSO') }
end
child line: :line do
  attributes :code, :denominacao, :retorno, :origem, :circular
end
