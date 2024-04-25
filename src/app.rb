# frozen_string_literal: true

require 'pg'
require 'debug'
require 'dotenv'
require_relative 'modules/pgdb'
require_relative 'modules/user'
require_relative 'modules/filament'

Dotenv.load('../.env')

class MakerNet < Sinatra::Base
  enable :sessions

  before do
    @user = nil
    @admin = false
    allowed = %w[/login / /register]

    if !allowed.include?(request.path_info) && session[:user_id].nil?
      session[:redirect] = request.path_info
      redirect '/login'
    end

    unless session[:user_id].nil?
      @user = user_db.get_user(session[:user_id]) if session[:user_id]
      @admin = user_db.get_user_server_permissions(@user).positive?
    end
  end

  def db
    return @db if @db

    @db = PgDb.new
  end

  def user_db
    return @user_db if @user_db

    @user_db = User.new
  end

  def filament_db
    return @filament_db if @filament_db

    @filament_db = Filament.new
  end

  helpers do
    def h(text)
      Rack::Utils.escape_html(text)
    end
  end

  get '/login' do
    redirect '/' unless session[:user_id].nil?
    erb :'account/login', layout: false
  end

  post '/login' do
    username = params['username'].downcase
    username = h(username)
    password = h(params['password'])

    user = if username.include? '@'
             user_db.get_username_by_mail(username.downcase)
           else
             user_db.get_user_by_username(username)
           end

    redirect '/login' if user.nil?

    user_password = BCrypt::Password.new(user['password'])

    if user_password == password
      session[:user_id] = user['id']
      target = '/'
      target = session[:redirect] if session[:redirect]
      session[:redirect] = nil
      redirect target
    else
      redirect '/login'
    end
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  get '/register' do
    erb :'account/register', layout: false
  end

  post '/register' do
    name = h(params['name'])
    email = h(params['email'])
    username = h(params['username'].downcase)
    password = h(params['password'])

    hashed_password = BCrypt::Password.create(password)

    new_user_id = user_db.register_new_user(name, username, email, hashed_password)

    p new_user_id['id']
    p username
    p password
    user = user_db.get_user(new_user_id['id'])
    session[:user_id] = user['id']
    redirect '/'
  end

  get '/profile' do
    @title = @user['name']
    erb :'account/profile'
  end

  get '/' do
    @title = 'MakerNet'
    redirect '/dashboard' unless @user.nil?
    erb :index
  end

  get '/dashboard' do
    @title = 'Dashboard'
    erb :'account/dashboard'
  end

  get '/admin' do
    redirect '/' unless @admin
    @title = 'Admin'
    erb :'admin/dashboard'
  end

  get '/filament' do
    @title = 'Filament'

    to_sort = %w[color material vendor weight]
    @filter_data = { 'group' => filament_db.get_all_filament_groups }

    to_sort.each do |key|
      @filter_data[key] = filament_db.get_all_json_keys(key)
    end

    @data = filament_db.get_filament
    erb :'filament/index'
  end

  get '/filament/:id' do |id|
    @data = filament_db.get_filament(id)[0]
    @title = @data['name']
    erb :'filament/show'
  end

end
