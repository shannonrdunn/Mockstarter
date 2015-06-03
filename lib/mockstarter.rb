require "mockstarter/version"
require "redis"
require "json"


## Core Mockstarter module
## There are two main classes, Fund and Project. Fund is for mainly funding
## a project and checking CC info. Project is for manipulation of Projects and
## users.

module Mockstarter
  class Fund
    VALID_PARAMS = [
      "username",
      "projectname",
      "amount",
      "creditcard",
      "redis"
    ].freeze

    def initialize(params)
      ## Cast each param as a instance variable.
      params.each do |key, value|
       if value && VALID_PARAMS.include?(key.to_s)
         instance_variable_set("@#{key}", value)
       end
      end if params.is_a? Hash
      ## round amount to nearest 100th
      @amount = (@amount.to_f * 100).round / 100.00
    end

    def transaction
      ## Call this method on the object and it will verify your card number
      ## and then pass the values to fund the project
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
      ## Credit card verifications tests
      case
      when @creditcard.to_s.size > 19
        fail ArgumentError, "Credit card number too large (must be less than 19)."
      when luhn_check == false
        fail ArgumentError, "Not valid card."
      when duplicate_card == true
        fail ArgumentError, "Credit taken by another user"
      end
      return true
    end

    def luhn_check
      ## Luhn check stolen from wikipedia, not my code.
      ## works great
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
      ## Check for duplicate card
      ## Pulls all users, deletes your own, looks up card for each user.
      all_users = @redis.smembers('user_set')
      all_users.delete(@username)
      all_users.map { |u|
        if @redis.get('user:creditcard:' + u) == @creditcard
          return true
        end
      }
      return false
    end

    def log
      ## Log all user transactions
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
      "goal",
      "redis"
    ].freeze

    def initialize(params)
      ## Read params, set as instance variables
      params.each do |key, value|
       if value && VALID_PARAMS.include?(key.to_s)
         instance_variable_set("@#{key}", value)
       end
      end if params.is_a? Hash

      @progress = progress
      @goal = (@goal.to_f * 100).round / 100.00
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
      ## Log new transactions for projects
      array = Array.new
      transactions = @redis.hgetall('project:transaction:' + @projectname)
      transactions.map { |k,v|
        array.push("#{k} backed for $#{v}")
      }
      return array
    end

    def funded
      ## is Project success yet? return boolean if true if false returns how much more it needs
      goal = @redis.get('project:goal:' + @projectname)
      unless goal == nil
        if @progress >= goal.to_i
          return true
        else
          return goal.to_i - @progress
        end
      end
      return false
    end

    def name_verify
      ## Tests for size, and characters in string, and if it already exists.
      case
      when @projectname.size < 4
        fail ArgumentError, "Project name is too short(less than 4 characters)"
      when @projectname.size > 19
        fail ArgumentError, "Project name is too large(more than 19 characters)"
      when (@projectname =~ /[^a-zA-Z0-9\-\_]/) != nil
        fail ArgumentError, "Project names can only have a-zA-Z, -, _"
      when @redis.get('project:goal:' + @projectname) != nil
        fail ArgumentError, "Project already exists!"
      end
        return true
    end

  end
end
