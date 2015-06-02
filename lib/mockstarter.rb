#require "mockstarter/version"
require "redis"
require "json"

module Mockstarter

  class Fund
    VALID_PARAMS = [
      "username",
      "projectname",
      "amount",
      "creditcard"
    ].freeze

    def initialize(params)
      params.each do |key, value|
       if value && VALID_PARAMS.include?(key.to_s)
         instance_variable_set("@#{key}", value)
       end
      end if params.is_a? Hash
      @redis = Redis.new(:host => "192.168.59.103",
                          :port => 6379)
    end


    def transaction
      id = Time.now.to_i.to_s
      @redis.set('user:creditcard:' + @username,
                    @creditcard)
      @redis.hset('user:transaction:' + @username,
                    @projectname + ":" + id,
                    @amount)
      @redis.hset('project:transaction:' + @projectname,
                    @username + ":" + id,
                    @amount)
    end

    def card_check
      ### TODO: create credit card check
    end

    def list_user
      puts @redis.hgetall('user:transaction:' + @username)
    end

  end


  class Project
    VALID_PARAMS = [
      "projectname",
      "goal"
    ].freeze

    def initialize(params)
      # Read params, set as instance variables
      params.each do |key, value|
       if value && VALID_PARAMS.include?(key.to_s)
         instance_variable_set("@#{key}", value)
       end
      end if params.is_a? Hash

      @redis = Redis.new(:host => "192.168.59.103",
                          :port => 6379)
      @progress = progress
    end

    def create
      # Creat a project and goal
      @@redis.set('project:goal:' + @projectname,
                   @goal)
    end

    def progress
      # Count  and return total contributions
      total = 0
      transactions = @redis.hgetall('project:transaction:' + @projectname)
      transactions.map { |k,v|
        total = total + v.to_i
      }
      return total
    end

    def funded
      # is Project success yet? true or false
      if progress >= @goal
        return true
      else
        return false
      end
    end

  end
end
