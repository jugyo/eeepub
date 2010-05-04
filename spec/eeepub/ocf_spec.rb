require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'tmpdir'
require 'fileutils'

describe "EeePub::OCF" do
  before do
    @tmpdir = File.join(Dir.tmpdir, 'eeepub_test')
    FileUtils.mkdir_p(@tmpdir)
    @container = EeePub::OCF::Container.new('foo.opf')
    @ocf = EeePub::OCF.new(:dir => @tmpdir, :container => @container)
  end

  after do
    FileUtils.rm_rf(@tmpdir)
  end

  it 'should return rootfiles' do
    @container.rootfiles.should == [{:full_path => 'foo.opf', :media_type => 'application/oebps-package+xml'}]
  end

  it 'should specify container as String' do
    ocf = EeePub::OCF.new(:dir => @tmpdir, :container => 'foo.opf')
    ocf.container.rootfiles == [{:full_path => 'foo.opf', :media_type => 'application/oebps-package+xml'}]
  end

  it 'should make xml' do
    doc  = Nokogiri::XML(@container.to_xml)
    rootfiles = doc.at('rootfiles')
    rootfiles.should_not be_nil
    rootfiles.search('rootfile').each_with_index do |rootfile, index|
      expect = @container.rootfiles[index]
      rootfile.attribute('full-path').value.should == expect[:full_path]
      rootfile.attribute('media-type').value.should == expect[:media_type]
    end
  end

  it 'should make epub' do
    output_path = File.join(Dir.tmpdir, 'eeepub_test.epub')
    @ocf.make(output_path)
    File.exists?(output_path)
  end
end
