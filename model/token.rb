# frozen_string_literal: true

require "active_record"

class Token < ActiveRecord::Base
  belongs_to :application
end
