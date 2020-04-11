# frozen_string_literal: true

require "singleton"
require "lazy-strans-client"

# StransApi wrapper
class StransAPi
  @@instance_ = nil

  def initialize(client)
    @client = client
  end

  # return instance if exists or new isntance with params default
  def self.instance
    @@instance_ = StransAPi.new(StransClient.new(
                                  ENV["STRANS_MAIL"],
                                  ENV["STRANS_PASS"],
                                  ENV["STRANS_KEY"]
                                )) unless @@instance_
    @@instance_
  end

  # call api strans
  def get(path, search = nil)
    @client.get(path, search) rescue nil
  end

  RAIO_TERRA = 6378.137 # KM

  # return all Stops closes coods.
  def stops_proximas(long, lat, dist, sources = nil)
    stops = []
    sources ||= Stop.all
    sources.each do |stop|
      next unless !stop.long.nil? && !stop.long.nil?

      dLong = calc_distan(long, stop.long)
      dLat = calc_distan(lat, stop.lat)

      # mutiplicacao do sen da metade da distancia da Lat;
      msmdl = Math.sin(dLat / 2) * Math.sin(dLat / 2)
      # mutiplicaçao cos da Latitude * PI
      mclPI = Math.cos(lat * Math::PI / 180) * Math.cos(stop.lat * Math::PI / 180)
      # mutiplicacao da metade do seno
      mmds = Math.sin(dLong / 2) * Math.sin(dLong / 2)
      a = msmdl + mclPI * mmds

      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
      d = RAIO_TERRA * c
      dist_stop = d * 1000 # distancia em metros

      if dist_stop < dist
        stop.dist = dist_stop # metros
        stops << stop
      end
    end
    stops.sort! { |a, b| a.dist <=> b.dist }
  end

  private

  # Calc dist positions.
  def calc_distan(pos1, pos2)
    (pos1 - pos2) * Math::PI / 180
  end
end
