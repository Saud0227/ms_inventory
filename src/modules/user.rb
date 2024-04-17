require 'pg'
require 'debug'

class User < PgDb
  def get_user_by_username(username)
    db_exec("SELECT * FROM users WHERE username = '#{username}'").first
  end

  def get_user(id)
    get_resource_by_id('users', id)
  end

  def get_username_by_mail(mail)
    db_exec("SELECT * FROM users WHERE email = '#{mail}'").first
  end

  def register_new_user(name, username, email, password)
    new_line = { name: name, username: username, email: email, password: password }
    insert_by_hash('users', new_line)
  end

  def rules(id)
    get_rule(id, '*')
  end

  def get_user_server_permissions(user)
    rules = get_all_rules_by_user(user, '*')
    # get max value of key 'value' from all rules
    current_max = 0
    rules.each do |rule|
      val = rule['value'].to_i
      current_max = val if val > current_max
    end
    current_max
  end

  private

  def get_rule(id, select)
    get_resource_by_id('rules', id, select)
  end

  def get_all_rules_by_user(user, select)
    teams = get_user_teams(user['id'])
    rules = []
    teams.each do |team|
      item = get_rules_by_team(team['team_id'])
      item.each do |rule|
        rules << rule
      end
    end

    item = get_rules_by_user(user['id'])
    item.each do |rule|
      rules << rule
    end

    rules.map! { |rule| get_rule(rule['rule_id'], select) }
    rules
  end

  def get_user_teams(id)
    db_exec("SELECT team_id FROM user_teams WHERE user_id = #{id}")
  end

  def get_rules_by_team(id)
    db_exec("SELECT rule_id FROM rules_teams WHERE team_id = #{id}")
  end

  def get_rules_by_user(id)
    db_exec("SELECT rule_id FROM rules_users WHERE user_id = #{id}")
  end

end
