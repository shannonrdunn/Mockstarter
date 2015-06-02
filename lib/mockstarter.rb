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
      # cast each param as a instance variable.
      params.each do |key, value|
       if value && VALID_PARAMS.include?(key.to_s)
         instance_variable_set("@#{key}", value)
       end
      end if params.is_a? Hash
      # establish redis connection
      @redis = Redis.new(:host => "192.168.59.103",
                         :port => 6379)
      # check luhn! if fail than exit, probably something better.
      unless luhn_check
        Raise "Not a valid credit card."
        exit
      end

    end


    def transaction
      @redis.sadd('user_set', @username)
  #    if card_unique
  #      raise "Credit card already in use by another user."
  #    else
        # Transaction id, based on unix epoch
        # needs to be done better
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
    end

    def luhn_check
      # Luhn check stolen from wikipedia, not my code.
      s1 = s2 = 0
      @creditcard.to_s.reverse.chars.each_slice(2) do |odd, even|
        s1 += odd.to_i

        double = even.to_i * 2
        double -= 9 if double >= 10
        s2 += double
      end
      (s1 + s2) % 10 == 0
    end

    def card_unique
      users = @redis.smembers('user_set')
      users.map { |e|
        if @redis.get('user:creditcard:' + e) == @creditcard
            e == @username
            return false
          end
        else
          return true
        end
      }
    end

    def list_user
      @redis.hgetall('user:transaction:' + @username)
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
      # Count and return total contributions
      total = 0
      transactions = @redis.hgetall('project:transaction:' + @projectname)
      transactions.map { |k,v|
        total = total + v.to_i
      }
      return total
    end

    def funded
      # is Project success yet? return boolean
      if progress >= @goal
        return true
      else
        return false
      end
    end
  end

end
