# frozen_string_literal: true

require 'pg'

class PgDb
  def initialize
    if Dir.pwd.split('/').last == 'app'
      host = 'postgres'
    else
      host = 'localhost'
    end
    @db_conn = PG.connect(host, 5432, nil, nil, 'postgres', 'postgres', ENV['PG_PASSWD'])
  end

  # @param [Integer] id
  def get_current_inventory(id = nil)
    select = 'i.*, p.name, p.vendor, p.image, p.type'
    if id
      response = db_exec("SELECT #{select} FROM inventory i lEFT JOIN products p ON i.product_id = p.id where i.id = #{id}").first
    else
      response = db_exec("SELECT #{select} FROM inventory i lEFT JOIN products p ON i.product_id = p.id")
    end
    response
  end

  # @param [Integer] id
  def get_products(id = nil)
    if id
      db_exec("SELECT * FROM products where id = #{id}").first
    else
      db_exec('SELECT * FROM products')
    end
  end

  private

  # @param [String] sql
  def db_exec(sql)
    @db_conn.exec(sql)
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

  # @param [String] table
  # @param [Integer, nil] id
  # @param [Array, nil] column
  def get_resource_by_id(table, id = nil, column = nil)
    select = if column.nil?
               '*'
             elsif column.is_a?(Array)
               ', '.join(column)
             elsif column.is_a?(String)
               column
             else
               '*'
             end

    if id
      db_exec("SELECT #{select} FROM #{table} WHERE id = #{id}").first
    else
      db_exec("SELECT #{select} FROM #{table}")
    end
  end

  # @param [String] table
  # @param [Integer] id
  def delete_from_table_by_id(table, id)
    db_exec("DELETE FROM #{table} WHERE id = #{id}")
  end
end
