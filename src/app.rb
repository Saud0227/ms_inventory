# frozen_string_literal: true

require 'pg'
require 'debug'
require 'dotenv/load'
require_relative 'db'

class MakerNet < Sinatra::Base
  def db
    return @db if @db

    # @db = PG.connect(dbname: 'PostgresMsInventoryCont', host: 'localhost', password: 'postgres123')
    # @db = PG.connect('localhost', 5432, nil, nil, 'postgres', 'postgres', ENV['PG_PASSWD'])
    @db = if ENV['PWD'].split('/').last == 'app'
            PgDb.new('postgres')
          else
            PgDb.new('localhost')
          end
  end

  get '/' do
    @title = 'MakerNet'
    erb :index
  end

  get '/inventory' do
    @data = db.get_current_inventory
    @title = 'Inventory'

    erb :'inventory/index'
  end

  get '/inventory/new' do
    @title = 'New Inventory'
    erb :'inventory/new'
  end

  post '/inventory' do
    data = {
      'product_id' => params['product_id'].to_i,
      'active' => params['active'] == 'on',
      'acquired_date' => "'#{params['date']}'"
    }
    result = db.insert_by_hash('inventory', data)

    redirect "/inventory/#{result}"
  end

  post '/inventory/:id/delete' do |id|
    db.delete_from_table_by_id('inventory', id)
    redirect '/inventory'
  end

  get '/inventory/:id' do
    @data =  db.get_current_inventory(params['id'])
    @title = @data['name']
    erb :'inventory/show'
  end

  get '/products' do
    @data =  db.get_products
    @title = 'Products'
    erb :'products/index'
  end

  get '/products/new' do
    @title = 'New Product'
    erb :'products/new'
  end

  post '/products' do
    name = params['name']
    vendor = params['vendor']
    description = params['description']
    type = params['type']
    query = "INSERT INTO products (name, vendor, description, type) VALUES ('#{name}','#{vendor}','#{description}','#{type}') RETURNING id"

    result = db.exec(query).first

    redirect "/products/#{result['id']}"
  end

  post '/products/:id/delete' do |id|
    db.delete_from_table_by_id('products', id)
    redirect '/products'
  end

  get '/products/:id' do
    @data =  db.get_products(params['id'])
    @title = @data['name']
    erb :'products/show'
  end
end
