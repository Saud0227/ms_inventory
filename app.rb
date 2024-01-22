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
    @data =  db.exec("SELECT i.*, p.name, p.vendor, p.image, p.type FROM inventory i lEFT JOIN products p ON i.product_id = p.id")
    @title = "Inventory"
    # puts @data
    erb :'inventory/index'
  end

  get '/inventory/new' do
    @title = "New Inventory"
    erb :'inventory/new'
  end

  post '/inventory' do
    # puts params
    product_id = params["product_id"].to_i
    active = params["active"] == "on"
    acquired = params["date"]
    query = "INSERT INTO inventory (product_id, active, acquired_date) VALUES (#{product_id},#{active},'#{acquired}') RETURNING id"
    # puts query
    result = db.exec(query).first
    # puts "!"
    # puts result
    # raise ValueError
    redirect "/inventory/#{result["id"]}"
  end

  post '/inventory/:id/delete' do |id|
    db.exec('DELETE FROM inventory WHERE id = $1', [id])
		redirect "/inventory"
  end


  get '/inventory/:id' do
    @data =  db.exec("SELECT i.*, p.name, p.vendor, p.image, p.type FROM inventory i lEFT JOIN products p ON i.product_id = p.id WHERE i.id = #{params[:id]}")[0]
    @title = @data["name"]
    erb :'inventory/show'
  end




  get '/products' do
    @data =  db.exec("SELECT * FROM products")
    @title = "Products"
    erb :'products/index'
  end

  get '/products/new' do
    @title = "New Product"
    erb :'products/new'
  end

  post '/products' do
    # puts params
    name = params["name"]
    vendor = params["vendor"]
    description = params["description"]
    type = params["type"]
    query = "INSERT INTO products (name, vendor, description, type) VALUES ('#{name}','#{vendor}','#{description}','#{type}') RETURNING id"
    # puts query
    result = db.exec(query).first
    # puts "!"
    # puts result
    # raise ValueError
    redirect "/products/#{result["id"]}"
  end
end


