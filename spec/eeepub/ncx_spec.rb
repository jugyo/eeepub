require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'tmpdir'
require 'fileutils'

describe "EeePub::NCX" do
  before do
    @ncx = EeePub::NCX.new(
      :uid => 'uid', :doc_title => 'title',
      :nav_points => [
        {:id => 'nav-1', :play_order => '1', :label => 'foo', :content => 'foo.html'},
        {:id => 'nav-2', :play_order => '2', :label => 'bar', :content => 'bar.html'}
      ]
    )
  end

  it 'should set default values' do
    @ncx.depth.should == 1
    @ncx.total_page_count.should == 0
    @ncx.max_page_number.should == 0
  end

  it 'should make xml' do
    doc  = Nokogiri::XML(@ncx.to_xml)
    head = doc.at('head')
    head.should_not be_nil

    head.at("//xmlns:meta[@name='dtb:uid']")['content'].should == 'uid'
    head.at("//xmlns:meta[@name='dtb:depth']")['content'].should == '1'
    head.at("//xmlns:meta[@name='dtb:totalPageCount']")['content'].should == '0'
    head.at("//xmlns:meta[@name='dtb:maxPageNumber']")['content'].should == '0'
    head.at("//xmlns:docTitle/xmlns:text").inner_text.should == 'title'

    nav_map = doc.at('navMap')
    nav_map.should_not be_nil
    nav_map.search('navPoint').each_with_index do |nav_point, index|
      expect = @ncx.nav_points[index]
      nav_point.attribute('id').value.should == expect[:id]
      nav_point.attribute('playOrder').value.should == expect[:play_order]
      nav_point.at('navLabel').at('text').inner_text.should == expect[:label]
      nav_point.at('content').attribute('src').value.should == expect[:content]
    end
  end
end
