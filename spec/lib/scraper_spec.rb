require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Scraper do 
  include Scraper
    before(:all) do
      @url = "http://www.google.lv"
    end
    
    it "should download HTML content" do
      download(@url).should =~ /<title>Google<\/title>/
    end
end