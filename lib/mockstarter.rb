#require "mockstarter/version"
require "redis"
require "json"

module Mockstarter

  class Fund
    @@redis = Redis.new(:host => "192.168.59.103",
                        :port => 6379)

    def transaction(username, projectname, amount, creditcard)
      id = Time.now.to_i.to_s
      @@redis.hset('user:creditcard:' + username,
                    creditcard)
      @@redis.hset('user:transaction:' + username,
                    projectname + ":" + id,
                    amount)
      @@redis.hset('project:transaction:' + projectname,
                    username + ":" + id,
                    amount)
    end

    def card_check(creditcard)
      ### TODO: create credit card check
    end

    def list_user(username)
      puts @@redis.hgetall('user:transaction:' + username)
    end

  end


  class Project
    @@redis = Redis.new(:host => "192.168.59.103",
                        :port => 6379)

    def create(projectname, goal)
      @@redis.set('project:goal:' + projectname,
                   goal)
    end

    def list(projectname)
      puts @@redis.hgetall('project:transaction:' + projectname)
      puts @@redis.get('project:goal:' + projectname)
    end

  end
end
