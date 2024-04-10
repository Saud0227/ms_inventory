# frozen_string_literal: true

require 'pg'

class PgDb

  def initialize(host)
    @db_conn = PG.connect(host, 5432, nil, nil, 'postgres', 'postgres', ENV['PG_PASSWD'])
  end

  # @param [Integer] id
  def get_current_inventory(id = nil)
    if id
      response = db_exec("SELECT i.*, p.name, p.vendor, p.image, p.type FROM inventory i lEFT JOIN products p ON i.product_id = p.id where i.id = #{id}").first
    else
      response = db_exec('SELECT i.*, p.name, p.vendor, p.image, p.type FROM inventory i lEFT JOIN products p ON i.product_id = p.id')
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

  def delete_from_table_by_id(table, id)
    db_exec("DELETE FROM #{table} WHERE id = #{id}")
  end

  def get_user_by_username(username)
    db_exec("SELECT * FROM users WHERE username = '#{username}'").first
  end

  def get_user_by_id(id)
    db_exec("SELECT * FROM users WHERE id = #{id}").first
  end

  def get_username_by_mail(mail)
    db_exec("SELECT username FROM users WHERE email = '#{mail}'").first
  end

  def register_new_user(name, username, email, password)
    query = 'INSERT INTO users (name, username, email, password)'
    query += "VALUES ('#{name}', '#{username}', '#{email}', '#{password}') RETURNING id"
    db_exec(query).first
  end

  private

  def db_exec(sql)
    @db_conn.exec(sql)
  end
end
