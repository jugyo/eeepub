require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'date'

describe "EeePub::OPF" do
  before do
    @opf = EeePub::OPF.new(
      :identifier => {:scheme => 'ISBN', :value => '978-4-00-310101-8'},
      :files => ['foo.html', 'bar.html', 'picture.png'],
      :ncx => 'toc.ncx'
    )
  end

  it 'should set default value' do
    @opf.toc.should == 'ncx'
    @opf.unique_identifier.should == 'BookId'
    @opf.title.should == 'Untitled'
    @opf.language.should == 'en'
  end

  it 'should export as xml' do
    doc  = Nokogiri::XML(@opf.to_xml)
    doc.at('package').attribute('unique-identifier').value.should == @opf.unique_identifier
    metadata = doc.at('metadata')
    metadata.should_not be_nil
    [
      ['dc:title', @opf.title],
      ['dc:language', @opf.language],
      ['dc:date', ''],
      ['dc:subject', ''],
      ['dc:description', ''],
      ['dc:relation', ''],
      ['dc:creator', ''],
      ['dc:publisher', ''],
      ['dc:rights', ''],
    ].each do |xpath, expect|
      metadata.xpath(xpath,
        'xmlns:dc' => "http://purl.org/dc/elements/1.1/").inner_text.should == expect
    end
    identifier = metadata.xpath('dc:identifier', 'xmlns:dc' => "http://purl.org/dc/elements/1.1/")[0]
    identifier.attribute('id').value.should == @opf.unique_identifier
    identifier.attribute('scheme').value.should == @opf.identifier[:scheme]
    identifier.inner_text.should == @opf.identifier[:value]

    manifest = doc.at('manifest')
    manifest.should_not be_nil
    manifest = manifest.search('item')
    manifest.size.should == 4
    manifest[0..2].each_with_index do |item, index|
      expect = @opf.manifest[index]
      item.attribute('id').value.should == expect
      item.attribute('href').value.should == expect
      item.attribute('media-type').value.should == @opf.guess_media_type(expect)
    end
    manifest[3].attribute('id').value.should == 'ncx'
    manifest[3].attribute('href').value.should == @opf.ncx
    manifest[3].attribute('media-type').value.should == @opf.guess_media_type(@opf.ncx)

    spine = doc.at('spine')
    spine.should_not be_nil
    spine = spine.search('itemref')
    spine.size.should == 2
    spine.each_with_index do |itemref, index|
      expect = @opf.spine[index]
      itemref.attribute('idref').value.should == expect
    end
  end

  context 'set all metadata' do
    before do
      @opf.set_values(
        :date => Date.today,
        :subject => 'subject',
        :description => 'description',
        :relation => 'relation',
        :creator => 'creator',
        :publisher => 'publisher',
        :rights => 'rights'
      )
    end

    it 'should export as xml' do
      doc  = Nokogiri::XML(@opf.to_xml)
      metadata = doc.at('metadata')
      metadata.should_not be_nil
      [
        ['dc:title', @opf.title],
        ['dc:language', @opf.language],
        ['dc:date', @opf.date.to_s],
        ['dc:subject', 'subject'],
        ['dc:description', 'description'],
        ['dc:relation', 'relation'],
        ['dc:creator', 'creator'],
        ['dc:publisher', 'publisher'],
        ['dc:rights', 'rights'],
      ].each do |xpath, expect|
        metadata.xpath(xpath,
          'xmlns:dc' => "http://purl.org/dc/elements/1.1/").inner_text.should == expect
      end
      identifier = metadata.xpath('dc:identifier', 'xmlns:dc' => "http://purl.org/dc/elements/1.1/")[0]
      identifier.attribute('id').value.should == @opf.unique_identifier
      identifier.attribute('scheme').value.should == @opf.identifier[:scheme]
      identifier.inner_text.should == @opf.identifier[:value]
    end
  end

  context 'plural identifiers' do
    before do
      @opf.identifier = [
        {:id => 'BookId', :scheme => 'ISBN', :value => '978-4-00-310101-8'},
        {:id => 'BookURL', :scheme => 'URL', :value => 'http://example.com/books/foo'}
      ]
    end

    it 'should export as xml' do
      doc  = Nokogiri::XML(@opf.to_xml)
      elements = doc.xpath('//dc:identifier', 'xmlns:dc' => "http://purl.org/dc/elements/1.1/")
      elements.size.should == 2
      elements.each_with_index do |element, index|
        expect = @opf.identifier[index]
        element.attribute('id').value.should == expect[:id]
        element.attribute('scheme').value.should == expect[:scheme]
        element.inner_text.should == expect[:value]
      end
    end
  end

  context 'plural languages' do
    before do
      @opf.language = ['ja', 'en']
    end

    it 'should export as xml' do
      doc  = Nokogiri::XML(@opf.to_xml)
      elements = doc.xpath('//dc:language', 'xmlns:dc' => "http://purl.org/dc/elements/1.1/")
      elements.size.should == 2
      elements.each_with_index do |element, index|
        element.inner_text.should == @opf.language[index]
      end
    end
  end

  context 'specify spine' do
    before do
      @opf.spine = ['a', 'b']
    end

    it 'should export as xml' do
      doc  = Nokogiri::XML(@opf.to_xml)
      spine = doc.at('spine')
      spine.should_not be_nil
      spine = spine.search('itemref')
      spine.size.should == 2
      spine.each_with_index do |itemref, index|
        expect = @opf.spine[index]
        itemref.attribute('idref').value.should == expect
      end
    end
  end

  context 'specify manifest as Hash' do
    before do
      @opf.manifest = [
        {:id => 'foo', :href => 'foo.html', :media_type => 'application/xhtml+xml'},
        {:id => 'bar', :href => 'bar.html', :media_type => 'application/xhtml+xml'},
        {:id => 'picture', :href => 'picture.png', :media_type => 'image/png'}
      ]
    end

    it 'should export as xml' do
      doc  = Nokogiri::XML(@opf.to_xml)
      manifest = doc.at('manifest')
      manifest.should_not be_nil
      manifest = manifest.search('item')
      manifest.size.should == 4
      manifest[0..2].each_with_index do |item, index|
        expect = @opf.manifest[index]
        item.attribute('id').value.should == expect[:id]
        item.attribute('href').value.should == expect[:href]
        item.attribute('media-type').value.should == expect[:media_type]
      end
      manifest[3].attribute('id').value.should == 'ncx'
      manifest[3].attribute('href').value.should == @opf.ncx
      manifest[3].attribute('media-type').value.should == @opf.guess_media_type(@opf.ncx)
    end
  end
end
