require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "EeePub::ContainerItem" do
  
  context 'guess media type' do

    before :each do
      @container_item = EeePub::ContainerItem.new []
    end

    it 'should be application/xhtml+xml' do
      media_type = 'application/xhtml+xml'
      ['test.htm', 'test.html', 'test.xhtm', 'test.xhtml'].each do |file_name|
        @container_item.send(:guess_media_type, file_name).should == media_type
      end
      @container_item.send(:guess_media_type, "test.xml").should_not == media_type
    end
  end

end