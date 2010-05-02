require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "EeePub::OPF" do
  before do
    @opf = EeePub::OPF.new(
      :title => 'title',
      :language => 'ja',
      :identifier => 'id',
      :items => [
        {:id => 'foo', :href => 'foo.html', :media_type => 'text/html'},
        {:id => 'bar', :href => 'bar.html', :media_type => 'text/html'},
        {:id => 'picture', :href => 'picture.png', :media_type => 'image/png'}
      ],
      :itemrefs => [
        {:idref => 'foo'},
        {:idref => 'bar'}
      ]
    )
  end

  it 'should export as xml' do
    doc  = Nokogiri::XML(@opf.to_xml)
    metadata = doc.at('metadata')
    metadata.should_not be_nil
    [
      ['dc:title', @opf.title],
      ['dc:language', @opf.language],
      ['dc:identifier', @opf.identifier],
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

    manifest = doc.at('manifest')
    manifest.should_not be_nil
    items = manifest.search('item')
    items.size.should == 3
    items.each_with_index do |item, index|
      expect = @opf.items[index]
      item.attribute('id').value.should == expect[:id]
      item.attribute('href').value.should == expect[:href]
      item.attribute('media-type').value.should == expect[:media_type]
    end

    spine = doc.at('spine')
    spine.should_not be_nil
    itemrefs = spine.search('itemref')
    itemrefs.size.should == 2
    itemrefs.each_with_index do |itemref, index|
      expect = @opf.itemrefs[index]
      itemref.attribute('idref').value.should == expect[:idref]
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
        ['dc:identifier', @opf.identifier],
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
    end
  end
end
