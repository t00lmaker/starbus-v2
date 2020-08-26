# frozen_string_literal: true

node(:token) { |_n| @jwt }
child @user do
  attributes :id, :name
end
child @app do
  attributes :id, :name
end
