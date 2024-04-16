# frozen_string_literal: true

require 'pg'
require 'debug'
require 'dotenv/load'
require_relative 'modules/db'

class MakerNet < Sinatra::Base
  enable :sessions

  before do
    allowed = %w[/login / /register]
    redirect '/login' if !allowed.include?(request.path_info) && session[:user_id].nil?
    unless session[:user_id].nil?
      @user = db.get_user_by_id(session[:user_id]) if session[:user_id]
    end

  end

  def db
    return @db if @db

    # @db = PG.connect(dbname: 'PostgresMsInventoryCont', host: 'localhost', password: 'postgres123')
    # @db = PG.connect('localhost', 5432, nil, nil, 'postgres', 'postgres', ENV['PG_PASSWD'])
    @db = PgDb.new

  end

  get '/login' do
    redirect '/' unless session[:user_id].nil?
    erb :'user/login', layout: false
  end

  post '/login' do
    username = params['username']
    username = db.get_username_by_mail(username) if username.include? '@'
    password = params['password']

    user = db.get_user_by_username(username)
    user_password = BCrypt::Password.new(user['password'])

    if user_password == password
      session[:user_id] = user['id']
      redirect '/'
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
    name = params['name']
    email = params['email']
    username = params['username']
    password = params['password']

    hashed_password = BCrypt::Password.create(password)

    new_user_id = db.register_new_user(name, username, email, hashed_password)

    p new_user_id['id']
    p username
    p password
    user = db.get_user_by_id(new_user_id['id'])
    session[:user_id] = user['id']
    redirect '/'
  end

  get '/profile' do
    @title = @user['name']
    erb :'user/profile'
  end

  get '/' do
    @title = 'MakerNet'
    erb :index
  end

  get '/test' do
    erb :test, layout: :new_layout
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
