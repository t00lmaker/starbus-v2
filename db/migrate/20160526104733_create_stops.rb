# frozen_string_literal: true

class CreateStops < ActiveRecord::Migration[6.0]
  def self.up
    create_table :stops do |t|
      t.string :code
      t.string :description
      t.text :address
      t.decimal :lat, :precision => 10, :scale => 6, :default => 0.0
      t.decimal :lng, :precision => 10, :scale => 6, :default => 0.0
      t.timestamps null: false
    end
  end

  def self.down
    drop_table :stops
  end
end
