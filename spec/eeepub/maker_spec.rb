require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "EeePub::Maker" do
  before do
    @maker = EeePub::Maker.new do
      title 'sample'
      creator 'jugyo'
      publisher 'jugyo.org'
      date "2010-05-06"
      identifier 'http://example.com/book/foo', :scheme => 'URL'
      uid 'http://example.com/book/foo'
    end
  end

  it { @maker.instance_variable_get(:@title).should == ['sample'] }
  it { @maker.instance_variable_get(:@creator).should == ['jugyo'] }
  it { @maker.instance_variable_get(:@publisher).should == ['jugyo.org'] }
  it { @maker.instance_variable_get(:@date).should == ["2010-05-06"] }
  it { @maker.instance_variable_get(:@identifier).should == [['http://example.com/book/foo', {:scheme => 'URL'}]] }
  it { @maker.instance_variable_get(:@uid).should == ['http://example.com/book/foo'] }
end
