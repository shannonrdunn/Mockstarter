require 'spec_helper'
describe Mockstarter do
  before(:all) do
    @redis = Redis.new(:url => ENV['MOCKSTARTER_BRAIN'], :db => 2)
    @project = Mockstarter::Project.new(:projectname => "test", :goal => 5000, :redis => @redis)
    @fund = Mockstarter::Fund.new(:username => 'test_user', :projectname => "test", :amount => 5000, :creditcard => 4111111111111111, :redis => @redis)
    @bad_card = Mockstarter::Fund.new(:creditcard => 4242424242424241, :redis => @redis)
    @dupe_card = Mockstarter::Fund.new(:username => 'test_user_dupe', :projectname => "test", :amount => 5000, :creditcard => 4111111111111111, :redis => @redis)
    @bad_project = Mockstarter::Project.new(:projectname => "tes*&^t", :goal => 5000, :redis => @redis)
  end
  after(:all) do
    ## Flush redis db after tests are done
    @redis.flushdb
  end
  it 'has a version number' do
    expect(Mockstarter::VERSION).not_to be nil
  end
  it 'creates a project with valid settings' do
    expect(@project.create).to eq("OK")
  end
  it 'funds the project' do
    expect(@fund.transaction).to eq(true)
  end
  it 'returns progress (funds) of test project' do
    expect(@project.progress).to eq(5000)
  end
  it 'bad luhn card number should raise ArgumentError' do
    expect { @bad_card.card_verify }.to raise_error(ArgumentError)
  end
  it 'detects duplicate card' do
    expect  raise_error(ArgumentError)
  end
  it 'bad name of project causes error' do
    expect { @bad_project.name_verify }.to raise_error(ArgumentError)
  end
end
