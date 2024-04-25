# frozen_string_literal: true

class Filament < PgDb
  def get_all_filament_groups
    raw = get_all_filament_groups_raw
    values = []
    raw.each { |item| values << item['group_id'] }
    values
  end

  def get_filament_groups(item_id)
    raw = get_mapped_id('items_groups', 'item', 'group', item_id)
    values = []
    raw.each do |item|
      values << get_resource_by_id('groups', item['group_id'])
    end
    values
  end

  def get_filament(id = nil)
    where = "type = 'filament'"
    where += " AND id = #{id}" if id
    raw = get_filament_adv('*', where)
    data = []
    raw.each do |item|
      JSON.parse(item['data']).each do |key, value|
        item[key] = value
      end
      item.delete('type')
      item.delete('data')
      item['groups'] = get_filament_groups(item['id'])
      data << item
    end
    data
  end

  def get_all_json_keys(keys)
    raw = db_exec(
      "SELECT DISTINCT data->> '#{keys}' as #{keys} FROM items WHERE type = 'filament'"
    )
    values = []
    raw.each { |item| values << item[keys] }
    values
  end

  private

  def get_all_filament_groups_raw
    db_exec("SELECT DISTINCT map.group_id FROM items_groups as map LEFT join items as i on i.id = map.item_id WHERE i.type = 'filament'")
  end

  def get_filament_adv(select, where)
    db_exec("SELECT #{select} FROM items WHERE #{where}")
  end
end
