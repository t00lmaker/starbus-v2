# frozen_string_literal: true

require 'singleton'
require 'lazy-strans-client'

# StransApi wrapper
class StransAPi
  @@instance_ = nil

  def initialize(client)
    @client = client
  end

  # return instance if exists or new isntance with params default
  def self.instance
    @@instance_ ||= StransAPi.new(StransClient.new(
                                    ENV['STRANS_MAIL'],
                                    ENV['STRANS_PASS'],
                                    ENV['STRANS_KEY']
                                  ))
    @@instance_
  end

  # call api strans
  def get(path, search = nil)
    @client.get(path, search)
  rescue StandardError
    nil
  end

  RAIO_TERRA = 6378.137 # KM

  # return all Stops closes coods.
  def nearby_stops(lng, lat, dist, sources = nil)
    stops = []
    sources ||= Stop.all
    sources.each do |stop|
      stops << stop if check_stop(stop, lng, lat, dist)
    end
    stops.sort! { |a, b| a.dist <=> b.dist }
  end

  private

  def check_stop(stop, lng, lat, dist)
    return false if stop.lng.nil? || stop.lat.nil?

    a = calc_area(stop, lng, lat)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    d = RAIO_TERRA * c
    dist_stop = d * 1000
    dist_stop < dist
  end

  def calc_area(stop, lng, lat)
    d_long = calc_dist(lng, stop.lng)
    d_lat  = calc_dist(lat, stop.lat)
    # mutiplicacao do sen da metade da distancia da Lat;
    msmdl = Math.sin(d_lat / 2) * Math.sin(d_lat / 2)
    # mutiplicacao cos da Latitude * PI
    mcl_pi = Math.cos(lat * Math::PI / 180) * Math.cos(stop.lat * Math::PI / 180)
    # mutiplicacao da metade do seno
    mmds = Math.sin(d_long / 2) * Math.sin(d_long / 2)
    msmdl + mcl_pi * mmds
  end

  # Calc dist positions.
  def calc_dist(pos1, pos2)
    (pos1 - pos2) * Math::PI / 180
  end
end
