# frozen_string_literal: true

require 'pg'
require 'debug'
require 'dotenv'
require_relative 'modules/pgdb'
require_relative 'modules/user'

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

  helpers do
    def h(text)
      Rack::Utils.escape_html(text)
    end
  end

  get '/login' do
    redirect '/' unless session[:user_id].nil?
    erb :'user/login', layout: false
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
    erb :'user/register', layout: false
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
    erb :'user/profile'
  end

  get '/' do
    @title = 'MakerNet'
    redirect '/dashboard' unless @user.nil?
    erb :index
  end

  get '/dashboard' do
    @title = 'Dashboard'
    erb :dashboard
  end

  get '/filament' do
    @title = 'Filament'
    erb :'filament/index'
  end

  # old routes
  # get '/inventory' do
  #   @data = db.get_current_inventory
  #   @title = 'Inventory'
  #
  #   erb :'inventory/index'
  # end
  #
  # get '/inventory/new' do
  #   @title = 'New Inventory'
  #   erb :'inventory/new'
  # end
  #
  # post '/inventory' do
  #   data = {
  #     'product_id' => params['product_id'].to_i,
  #     'active' => params['active'] == 'on',
  #     'acquired_date' => "'#{params['date']}'"
  #   }
  #   result = db.insert_by_hash('inventory', data)
  #
  #   redirect "/inventory/#{result}"
  # end
  #
  # post '/inventory/:id/delete' do |id|
  #   db.delete_from_table_by_id('inventory', id)
  #   redirect '/inventory'
  # end
  #
  # get '/inventory/:id' do
  #   @data =  db.get_current_inventory(params['id'])
  #   @title = @data['name']
  #   erb :'inventory/show'
  # end
  #
  # get '/products' do
  #   @data =  db.get_products
  #   @title = 'Products'
  #   erb :'products/index'
  # end
  #
  # get '/products/new' do
  #   @title = 'New Product'
  #   erb :'products/new'
  # end
  #
  # post '/products' do
  #   name = params['name']
  #   vendor = params['vendor']
  #   description = params['description']
  #   type = params['type']
  #   query = 'INSERT INTO products (name, vendor, description, type)'
  #   query += " VALUES ('#{name}', '#{vendor}', '#{description}', '#{type}') RETURNING id"
  #
  #   result = db.exec(query).first
  #
  #   redirect "/products/#{result['id']}"
  # end
  #
  # post '/products/:id/delete' do |id|
  #   db.delete_from_table_by_id('products', id)
  #   redirect '/products'
  # end
  #
  # get '/products/:id' do
  #   @data =  db.get_products(params['id'])
  #   @title = @data['name']
  #   erb :'products/show'
  # end
end
