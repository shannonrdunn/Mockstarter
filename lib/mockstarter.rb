require "mockstarter/version"
require "redis"
require "json"

module Mockstarter

  class Data
    def client
      redis = Redis.new(:host => "192.168.59.103", :port => 6379)
      return redis
    end
  end

  class Users
    def new_user
      Data.client.hmset("hash", "f1", "v1", "f2", "v2")
    end

    def backed
    end

  end

  class Payment

  end

  class Project

  end
end
