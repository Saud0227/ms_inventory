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
    erb :inventory
  end

end
