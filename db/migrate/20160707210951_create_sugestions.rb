# frozen_string_literal: true

class CreateSugestions < ActiveRecord::Migration[6.0]
  def self.up
    create_table :sugestions do |t|
      t.text :text, index: true
      t.belongs_to :user, index: true
      t.timestamps null: false
    end
  end

  def self.down
    drop_table :sugestions
  end
end
