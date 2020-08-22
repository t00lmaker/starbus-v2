# frozen_string_literal: true

collection @vehicles, root: :vehicles, object_root: false
attributes :code, :time, :lat, :long, :last_lat, :last_long
child :reputation do |ele|
  node(:time) { ele.avg('HORARIO') }
  node(:state) { ele.avg('ESTADO') }
  node(:safety) { ele.avg('SEGURANCA') }
  node(:comfort) { ele.avg('CONFORTO') }
  node(:accessibility) { ele.avg('ACESSIBILIDADE') }
end
child line: :line do
  attributes :code, :description, :return, :origin, :circular
end
