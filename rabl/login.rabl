node(:token) { |n| @jwt}
child @user do
  attributes :id, :name
end
child @app do
  attributes :id, :name
end

