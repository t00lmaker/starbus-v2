# frozen_string_literal: true

require 'grape'
require 'grape-rabl'
require 'jwt'

require './model/line'
require './model/stop'
require './model/vehicle'
require './model/reputation'
require './model/interaction'
require './model/checkin'
require './model/token'
require './model/user'
require './model/sugestion'
require './model/result'
require './model/application'
require './model/users_application'
require './lib/load_lines_stops'
require './lib/client_strans'
require './lib/bus_cache'

I18n.config.available_locales = :en

module StarBus
  # Api Starbus
  class API < Grape::API
    version 'v2'
    format :json
    formatter :json, Grape::Formatter::Rabl

    before do
      authenticate! unless route.settings[:public]
    end

    helpers do
      def load_auth
        @token = headers['Authorization'].dup
        return false if @token.nil?

        @token.slice!('Bearer ')
        payload = JWT.decode(@token, nil, false)[0]
        @current_user ||= User.find(payload['user_id'])
        @app_user ||= Application.find(payload['app_id'])
        @current_user && @app_user && in_user_app?(@app_user)
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless load_auth
      end

      def in_user_app?(app)
        @current_user.applications.include?(app)
      end

      def validate_app!(app)
        error!({ erro: 'Application not found', detalhe: 'Check id param' }, 404) unless app

        return if in_user_app?(app)

        error!({ erro: 'Access Error', detalhe: 'You do not have access' }, 401)
      end
    end

    desc 'Login application, return a jwt.'
    route_setting :public, true
    params do
      requires :username, desc: 'username/email para login.'
      requires :password, desc: 'password para login.'
    end
    post 'login', rabl: 'login.rabl' do
      @app = Application.find_by_key(params[:application])
      @user = User.find_by_username(params[:username])
      if @user && @user.password == params[:password]
        payload = {
          user_id: @user.id,
          app_id: @app.id,
          exp: Time.now.to_i + 15 * 3600
        }
        @jwt = JWT.encode(payload, nil, 'none')
        Token.create(jwt: @jwt, application: @app)
      else
        error!({ erro: 'Falha de autenticacão.', detalhe: 'Verifique os dados passados' }, 403)
      end
    end

    desc 'Return session by token'
    get 'session', rabl: 'login.rabl' do
      @app = @app_user
      @user = @current_user
      @jwt = @token
    end

    resource :applications do
      desc 'Create new application.'
      params do
        requires :name, desc: "Name's new application."
        requires :description, desc: 'Short description new application.'
      end
      post '/', rabl: 'application.rabl' do
        @application = Application.create(
          name: params[:name],
          description: params[:description],
          ownner: @current_user,
          users: [@current_user]
        )
      end

      desc 'Return all application.'
      get '/', rabl: 'applications.rabl' do
        @applications = Application.where(ownner: @current_user)
      end

      desc 'Return application by id.'
      params do
        requires :id, desc: "Id's application to find."
      end
      get ':id', rabl: 'application.rabl' do
        @application = begin
                         Application.find(params[:id])
                       rescue StandardError
                         nil
                       end
        validate_app!(@application)
      end

      desc 'Update application.'
      params do
        requires :id, desc: "Id's application to find."
        requires :name, desc: "Name's application"
        requires :description, desc: 'Short description new application.'
        requires :active, desc: 'Check application is active or not'
      end
      put ':id', rabl: 'application.rabl' do
        @application = begin
                         Application.find(params[:id])
                       rescue StandardError
                         nil
                       end
        validate_app!(@application)
        @application.update(
          name: params[:name],
          description: params[:description],
          active: params[:active]
        )
      end

      desc 'Disable application by id'
      params do
        requires :id, desc: "Application's id to disabled."
      end
      delete ':id', rabl: 'application.rabl' do
        @application = begin
                         Application.find(params[:id])
                       rescue StandardError
                         nil
                       end
        validate_app!(@application)
        @application.update(active: false)
      end
    end

    resource :users do
      desc 'Create new user.'
      params do
        requires :email, desc: "Emial's new user."
        requires :password, desc: "Password's new user."
        optional :name, desc: "Name's new user."
        optional :url_photo, desc: "Photo's new user."
      end
      route_setting :public, true
      post '/', rabl: 'user.rabl' do
        hash_pass = BCrypt::Password.create(params[:password])
        @user = User.create(
          name: params[:name],
          email: params[:email],
          password_hash: hash_pass,
          url_photo: params[:url_photo]
        )
      end

      desc 'Return all users.'
      get '/', rabl: 'users.rabl' do
        @users = User.all
      end

      desc 'Return user by id.'
      params do
        requires :id, desc: 'id'
      end
      get ':id', rabl: 'user.rabl' do
        @user = begin
                  User.find(params[:id])
                rescue StandardError
                  nil
                end
        error!({ erro: 'User not found', detalhe: 'Check id in param.' }, 404) unless @user
      end

      desc 'Update User by id.'
      params do
        requires :email, desc: "Emial's user."
        requires :password, desc: "Password's user."
        optional :name, desc: "Name's user."
        optional :url_photo, desc: "Photo's user."
      end
      put ':id', rabl: 'user.rabl' do
        @user = begin
                  User.find(params[:id])
                rescue StandardError
                  nil
                end
        if @user
          @user.update(params)
        else
          error!({ erro: 'User not found', detalhe: 'Check id in param.' }, 404)
        end
      end

      desc 'Disable user by id'
      params do
        requires :id, desc: "User's id to disabled."
      end
      delete ':id', rabl: 'user.rabl' do
        @user = begin
                  User.find(params[:id])
                rescue StandardError
                  nil
                end
        if @user
          @user.update(active: false)
        else
          error!({ erro: 'User not found', detalhe: 'Check id in param.' }, 404)
        end
      end

      desc "Create a user's sugestion to api"
      params do
        optional :id, desc: "User's id"
        optional :email, desc: "User's email"
        requires :text, desc: 'Text of sugestion'
      end
      post ':id/sugestion' do
        if params[:id]
          @user = User.find(params[:id])
        elsif params[:email]
          @user = User.find_by_email(params[:email])
          @user ||= User.create(email: params[:email])
        end
        Sugestion.create(user: @user, text: params[:text])
      end
    end

    resource :lines do
      desc 'Return all  with filter in search to code, description, return'
      params do
        optional :search, desc: 'Term to search'
        optional :codes, type: Array, desc: 'códigos da lines que deseja'
      end
      get '/', rabl: 'lines.rabl' do
        search = params[:search]
        if search
          sql = 'code like ? OR description like ? OR return like ? OR origin like ?'
          search = ActiveSupport::Inflector.transliterate(search)
          split = search.upcase.split
          @lines = split.map do |s|
            Line.where(sql, "%#{s}%", "%#{s}%", "%#{s}%", "%#{s}%").order('code asc')
          end.reduce(:+)
        else
          codes = params[:codes]
          @lines = if codes
                     Line.where(code: params[:codes]).order('code asc')
                   else
                     Line.order(:code)
                   end
        end
      end

      desc 'Load all lines to source (API Integrah).'
      get 'load' do
        LoadLinesStops.new(StransAPi.instance).init
      end

      desc 'Return vehicles by line.'
      params do
        requires :code, desc: 'Line code to filter vehicles.'
      end
      get ':code/vehicles', rabl: 'vehicles.rabl' do
        @vehicles = BusCache.instance.get_by_line(params[:code])
      end
    end

    resource :stops do
      desc 'Return all stops filter by codes'
      params do
        optional :codes, type: Array, desc: 'Stop codes to return.'
      end
      get '/', rabl: 'stops_basic.rabl' do
        @stops = if params[:codes]
                   Stop.where(code: params[:codes]).order('code asc')
                 else
                   Stop.order('code asc')
                 end
      end

      desc 'Return lines by stop.'
      params do
        requires :code, type: String, desc: 'Stop code to return lines.'
      end
      get ':code/lines', rabl: 'lines.rabl' do
        stop = Stop.find_by_code(params[:code])
        if stop
          @lines = stop.lines.order('code ASC')
        else
          error!({ erro: 'Stop not found', detalhe: 'Stop by code not found' }, 404)
        end
      end

      desc 'Return stops closes to localization.'
      params do
        requires :lat, type: Float
        requires :lng, type: Float
        requires :dist, type: Float
      end
      get 'closes', rabl: 'stops.rabl' do
        strans = StransAPi.instance
        @stops = strans.nearby_stops(params[:lng], params[:lat], params[:dist])
        if !@stops || @stops.empty?
          @stops = strans.nearby_stops(params[:lng], params[:lat], (params[:dist] * 2))
        end
      end

      desc 'Create checkin to stop with code.'
      params do
        requires :code, desc: 'Stop code to checkin.'
      end
      post '/:code/checkin' do
        stop = Stop.find_by_code(params[:code])
        if stop
          Checkin.create(user: @current_user, stop: stop)
        else
          error!({ erro: 'Stop not found', detalhe: 'Stop by code not found' }, 404)
        end
      end
    end

    resource :vehicles do
      desc 'Return all vehicles.'
      get '/', rabl: 'vehicles.rabl' do
        @vehicles = BusCache.instance.all
      end

      desc 'Return vehicle by code.'
      params do
        requires :code, desc: 'Code vehicle to return.'
      end
      get '/:code', rabl: 'vehicle.rabl' do
        @vehicle = BusCache.instance.get(params[:code])
        error!({ erro: 'Vehicle not found.', detalhe: 'Verify code param.' }, 404) unless @vehicle
      end

      desc 'Create checkin to vehicle with code.'
      params do
        requires :code, desc: 'Code vehicle to checkin.'
      end
      post ':code/checkin' do
        vehicle = BusCache.instance.get(params[:code])
        if vehicle
          Checkin.create(user: @current_user, vehicle: vehicle)
        else
          error!({ erro: 'Vehicle not found', detalhe: 'Vehicle is not online.' }, 404)
        end
      end
    end

    params do
      requires :type, values: %w[con seg mov pon ace est]
      requires :code
    end
    resource :interactions do
      get ':type/stop/:code', rabl: 'interactions.rabl' do
        @type = Interaction.type_s[params[:type]]
        stop = Stop.find_by_code(params[:code])
        error!({ erro: 'Stop not found', detalhe: 'Verify code param.' }, 404) unless stop
        @reputation = stop.reputation
        @interactions = @reputation.interactions_type(@type)
      end

      get ':type/vehicle/:code', rabl: 'interactions.rabl' do
        code = params[:code]
        @type = Interaction.type_s[params[:type]]
        vehicle = Vehicle.find_by_code(code)
        error!({ erro: 'Vehicle nof found', detalhe: 'Verify code param.' }, 404) unless vehicle
        @reputation = vehicle.reputation
        @interactions = @reputation.interactions_type(@type)
      end

      params do
        requires :evaluation, values: Interaction.evaluations.values
        requires :comment
      end
      post ':type/stop/:code', rabl: 'result.rabl' do
        i = Interaction.new
        i.user = @current_user
        i.type_ = params[:type]
        i.comment = params[:comment]
        i.evaluation = params[:evaluation]
        @result = Result.new
        stop = Stop.find_by_code(params[:code])
        if stop
          stop.reputation ||= Reputation.new
          stop.reputation.interactions << i
          @result.status = stop.save! ? 'sucess' : 'error'
        else
          @result.status = 'error'
          @result.mensage = 'Stop not found.'
        end
      end

      params do
        requires :evaluation, values: Interaction.evaluations.values
        requires :comment
        requires :id_facebook
      end
      post ':type/vehicle/:code', rabl: 'result.rabl' do
        i = Interaction.new
        i.user = User.find_by_id_facebook(params[:id_facebook])
        i.type_ = params[:type]
        i.comment = params[:comment]
        i.evaluation = params[:evaluation]
        @result = Result.new
        vehicle = Vehicle.find_by_code(params[:code])
        if vehicle
          vehicle.reputation ||= Reputation.new
          vehicle.reputation.interactions << i
          @result.status = vehicle.save! ? 'sucess' : 'error'
        else
          @result.mensage = 'Vehicle not found.'
        end
      end
    end
  end
end
