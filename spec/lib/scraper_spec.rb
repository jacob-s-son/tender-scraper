require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Scraper do 
  describe "#determine_tender_country" do
    context "when valid url is passed" do
      context "when defined domain is passed" do
          subject { Scraper::Parser.new "http://www.google.lv" } 
          its (:determine_tender_country) { should == :lv }
      end
      
      context "when undefined domain is passed" do
        subject { Scraper::Parser.new "http://www.google.com" } 
        its(:determine_tender_country) { should == :lt }
      end
    end
  end
end