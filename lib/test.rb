load 'mockstarter.rb'


fund = Mockstarter::Fund.new(:username => "sdunn", :projectname => "kung fury", :amount => 823, :creditcard => 4342562230449520)
project = Mockstarter::Project.new(:projectname => "kung fury", :goal => 50000)
