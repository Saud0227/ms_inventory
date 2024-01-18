require 'pg'
require 'debug'
require 'dotenv/load'

class MakerNet < Sinatra::Base

  def db
    return @db if @db
    # @db = PG.connect(dbname: 'PostgresMsInventoryCont', host: 'localhost', password: 'postgres123')
    @db = PG.connect( 'localhost', 5432, nil, nil, 'postgres', 'postgres', ENV['PG_PASSWD'])
  end

  get '/' do
    @title = "MakerNet"
    erb :index
  end

  get '/inventory' do
    @data =  db.exec("SELECT * FROM inventory lEFT JOIN products ON inventory.product_id = products.id")
    @title = "Inventory"
    puts @data
    erb :'inventory/index'
  end

  get '/inventory/new' do
    @title = "New Inventory"
    erb :'inventory/new'
  end

  post '/inventory/' do
    puts params
    product_id = params["product_id"].to_i
    active = params["active"] == "on"
    acquired = params["date"]
    query = "INSERT INTO inventory (product_id, active, acquired_date) VALUES (#{product_id},#{active},'#{acquired}') RETURNING id"
    puts query
    result = db.exec(query).first
    puts "!"
    puts result
    # raise ValueError
    redirect "/inventory/#{result["id"]}"
  end

  get '/inventory/:id' do
    @data =  db.exec("SELECT * FROM inventory lEFT JOIN products ON inventory.product_id = products.id WHERE inventory.id = #{params[:id]}")
    @title = "Inventory"
    puts @data
    erb :'inventory/show'
  end

end
