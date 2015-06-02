require 'spec_helper'
describe Mockstarter do
  it 'has a version number' do
    expect(Mockstarter::VERSION).not_to be nil
  end

  describe Mockstarter::Fund do
    before do
      @good_card = Mockstarter::Fund.new(:creditcard => 378282246310005)
      @bad_card = Mockstarter::Fund.new(:creditcard => 4242424242424241)
      @long_card = Mockstarter::Fund.new(:creditcard => 424242424242424121211231231232)
    end
    it 'good card number should pass card verification' do
      @good_card.card_verify == true
    end
    it 'bad luhn card number should raise ArgumentError' do
      expect { @bad_card.card_verify }.to raise_error(ArgumentError)
    end
    it 'long card number should raise ArgumentError' do
      expect { @long_card.card_verify }.to raise_error(ArgumentError)
    end
  end

  describe Mockstarter::Project do
    before do
      @good_name = Mockstarter::Project.new(:projectname => 'Project')
      @short_name = Mockstarter::Project.new(:projectname => 'Pro')
    end
    it 'good name should pass name verification' do
      @good_name.name_verify == true
    end
    it 'short name should raise ArgumentError' do
      expect { @short_name.name_verify }.to raise_error(ArgumentError)
    end
  end
end
