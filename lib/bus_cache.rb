# frozen_string_literal: true

require 'singleton'
require 'lazy-strans-client'
require 'timerizer'
require_relative '../model/vehicle'
require_relative '../model/snapshot'
require_relative '../model/line'

# Cache buses
class BusCache
  @@instance_ = nil
  # time to new request api
  LIMIT_TIME_UPDATE = 20.seconds
  # time to vehicle valid
  LIMIT_TIME_VEI = 5.minute
  # time to save snaptshot
  LIMIT_TIME_SAVE = 5.minute

  def initialize(client)
    @client = client
  end

  # return instance if exists or new isntance with params default
  def self.instance
    @@instance_ ||= BusCache.new(
      StransAPi.instance
    )
    @@instance_
  end

  # return all vehicles in cache
  def all
    update
    valids(@buses_by_code.values)
  end

  # return vehicles by code by cache
  def get(code)
    update
    return nil unless @buses_by_code[code]

    valid?(@buses_by_code[code].time) ? @buses_by_code[code] : nil
  end

  # return all vehicles by line in cache
  def get_by_line(cod_line)
    update
    vehicles = @client.get(:veiculos_linha, cod_line)
    load_in_map(vehicles)
    vehicles = @buses_by_line[cod_line]
    vehicles ? valids(vehicles.values) : nil
  end

  # cache is updated?
  def updated?
    @last_update && @last_update >= LIMIT_TIME_UPDATE.ago
  end

  private

  # return time to Brasilia
  def now
    Time.now.utc.localtime('-03:00')
  end

  # check valid time to bus
  def valid?(time)
    time_as_array = time.split(':')
    hash_h = { hour: time_as_array[0].to_i, min: time_as_array[1].to_i }
    time_veic = now.change(hash_h)
    time_veic >= LIMIT_TIME_VEI.ago && time_veic <= LIMIT_TIME_VEI.from_now
  end

  def valids(buses)
    buses&.select { |v| valid?(v.time) }
  end

  # update vehicles by api strans
  def update
    unless updated?
      reset if !@last_update || @last_update.day != now.day
      @last_update = now
      vehicles = @client.get(:veiculos)
      load_in_map(vehicles)
    end
    save_snapshot
  end

  def load_in_map(vehicles)
    return if vehicles.nil? || vehicles.is_a?(ErroStrans)

    vehicles.select { |v| valid?(v.hora) }.each do |vehicle|
      put_maps(load_or_save(vehicle))
    end
  end

  def put_maps(vehicle)
    @buses_by_code[vehicle.code] = vehicle
    @buses_by_line[vehicle.line.code] ||= {}
    @buses_by_line[vehicle.line.code][vehicle.code] = vehicle
  end

  def load_or_save(vehicle_strans)
    code = vehicle_strans.codigoVeiculo
    vehicle = Vehicle.find_by_code(code)
    vehicle ||= Vehicle.create(code: code, reputation: Reputation.new)
    vehicle.merge(vehicle_strans)
    load_last_position(vehicle)
    vehicle
  end

  def load_last_position(vehicle)
    last_vehicle = @buses_by_code[vehicle.code]
    return unless last_vehicle

    if last_vehicle.lat == vehicle.lat && last_vehicle.long == vehicle.long
      vehicle.last_lat = last_vehicle.last_lat
      vehicle.last_long = last_vehicle.last_long
    else
      vehicle.last_lat = last_vehicle.lat
      vehicle.last_long = last_vehicle.long
    end
  end

  def reset
    @buses_by_code = {}
    @buses_by_line = {}
    @last_update = nil
  end

  def save_snapshot
    return if @last_save && @last_save > LIMIT_TIME_SAVE.ago

    lines_buses = {}
    @buses_by_line.each do |k, v|
      lines_buses[k] = v.values
    end
    Snapshot.create({ value: lines_buses.to_json, data: Time.now - 3.hours })
    @last_save = now
  end
end
