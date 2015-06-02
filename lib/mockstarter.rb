require "mockstarter/version"
require "redis"
require "json"


## Core Mockstarter module
## There are two main classes, Fund and Project. Fund is for mainly funding
## a project and checking CC info. Project is for manipulation of Projects and
## users.

## TODO: Handle errors for existing projects, and credit cards.
## TODO: Moar tests.

module Mockstarter
  class Fund
    VALID_PARAMS = [
      "username",
      "projectname",
      "amount",
      "creditcard"
    ].freeze

    def initialize(params)
      ## Cast each param as a instance variable.
      params.each do |key, value|
       if value && VALID_PARAMS.include?(key.to_s)
         instance_variable_set("@#{key}", value)
       end
      end if params.is_a? Hash
      ## Establish redis connection, from environment variable
      @redis = Redis.new(:url => ENV['MOCKSTARTER_BRAIN'])
    end

    def transaction
      unless card_verify == false
        @redis.sadd('user_set', @username)
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

    def card_verify
      case
      when @creditcard.to_s.size > 19
        fail ArgumentError, "Credit card number too large (must be less than 19)."
      when luhn_check == false
        fail ArgumentError, "Not valid card."
      when duplicate_card == true
        fail ArgumentError, "Credit taken by another user"
      when duplicate_card == true
        fail ArgumentError, "Credit taken by another user"
      end
      return true
    end

    def luhn_check
      ## Luhn check stolen from wikipedia, not my code.
      s1 = s2 = 0
      @creditcard.to_s.reverse.chars.each_slice(2) do |odd, even|
        s1 += odd.to_i

        double = even.to_i * 2
        double -= 9 if double >= 10
        s2 += double
      end
      (s1 + s2) % 10 == 0
    end

    def duplicate_card
      all_users = @redis.smembers('user_set')
      all_users.delete(@username)
      all_users.map { |u|
        puts u
        if @redis.get('user:creditcard:' + u) == @creditcard
          return true
        end
      }
      return false
    end

    def log
      array = Array.new
      transactions = @redis.hgetall('user:transaction:' + @username)
      transactions.map { |k,v|
        array.push("Backed #{k} for $#{v}")
      }
      return array
    end
  end

  class Project
    VALID_PARAMS = [
      "projectname",
      "goal"
    ].freeze

    def initialize(params)
      ## Read params, set as instance variables
      params.each do |key, value|
       if value && VALID_PARAMS.include?(key.to_s)
         instance_variable_set("@#{key}", value)
       end
      end if params.is_a? Hash

      @redis = Redis.new(:url => ENV['MOCKSTARTER_BRAIN'])
      @progress = progress
    end

    def create
      ## Ensure name passes verification, then create the project in redis.
      unless name_verify == false
        @redis.set('project:goal:' + @projectname,
                     @goal)
      end
    end

    def progress
      # Count and return total contributions for a given project
      total = 0
      transactions = @redis.hgetall('project:transaction:' + @projectname)
      transactions.map { |k,v|
        total = total + v.to_i
      }
      return total
    end

    def log
      array = Array.new
      transactions = @redis.hgetall('project:transaction:' + @projectname)
      transactions.map { |k,v|
        array.push("#{k} backed for $#{v}")
      }
      return array
    end

    def funded
      ## is Project success yet? return boolean
      if @progress >= @redis.get('project:goal:' + @projectname).to_i
        return true
      else
        return false
      end
    end

    def name_verify
      ## TODO: Test cases for bad names.
      case
      when @projectname.size < 4
        fail ArgumentError, "Project name is too short(less than 4 characters)"
      when @projectname.size > 19
        fail ArgumentError, "Project name is too large(more than 19 characters)"
      when @redis.get('project:goal:' + @projectname) != nil
        fail ArgumentError, "Project already exists!"
      end
        return true
    end

  end
end
