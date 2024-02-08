# frozen_string_literal: true
require 'pg'

class PgDb

  def initialize
    @db_conn = PG.connect('localhost', 5432, nil, nil, 'postgres', 'postgres', ENV['PG_PASSWD'])
  end

  # @param [Integer] id
  def get_current_inventory(id=nil)
    if id
      response = db_exec("SELECT i.*, p.name, p.vendor, p.image, p.type FROM inventory i lEFT JOIN products p ON i.product_id = p.id where i.id = #{id}").first
    else
      response = db_exec('SELECT i.*, p.name, p.vendor, p.image, p.type FROM inventory i lEFT JOIN products p ON i.product_id = p.id')
    end
    response
  end
  
  # @param [Integer] id
  def get_products(id=nil)
    if id
      db_exec("SELECT * FROM products where id = #{id}")
    else
      db_exec('SELECT * FROM products')
    end
  end
  
  # @param [String] table
  # @param [Hash] hash
  def insert_by_hash(table, hash)
    keys = hash.keys
    values = hash.values
    query = "INSERT INTO #{table} (#{keys.join(',')}) VALUES (#{values.join(',')}) RETURNING id"
    puts query
    result = db_exec(query).first
    result['id']
  end

  def delete_table_via_id(table, id)
    db_exec("DELETE FROM #{table} WHERE id = #{id}")
  end

  private
  
  
  def db_exec(sql)
    @db_conn.exec(sql)
  end


end

