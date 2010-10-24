require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "EeePub::Maker" do
  before do
    @maker = EeePub::Maker.new do
      title 'sample'
      creator 'jugyo'
      publisher 'jugyo.org'
      date "2010-05-06"
      language 'en'
      subject 'epub sample'
      description 'this is epub sample'
      rights 'xxx'
      relation 'xxx'
      identifier 'http://example.com/book/foo', :scheme => 'URL'
      uid 'http://example.com/book/foo'
      ncx_file 'toc.ncx'
      opf_file 'content.opf'
      files ['foo.html', 'bar.html']
      nav [
        {:label => '1. foo', :content => 'foo.html'},
        {:label => '1. bar', :content => 'bar.html'}
      ]
    end
  end

  it { @maker.instance_variable_get(:@titles).should == ['sample'] }
  it { @maker.instance_variable_get(:@creators).should == ['jugyo'] }
  it { @maker.instance_variable_get(:@publishers).should == ['jugyo.org'] }
  it { @maker.instance_variable_get(:@dates).should == ["2010-05-06"] }
  it { @maker.instance_variable_get(:@identifiers).should == [{:value => 'http://example.com/book/foo', :scheme => 'URL'}] }
  it { @maker.instance_variable_get(:@uid).should == 'http://example.com/book/foo' }
  it { @maker.instance_variable_get(:@ncx_file).should == 'toc.ncx' }
  it { @maker.instance_variable_get(:@opf_file).should == 'content.opf' }
  it { @maker.instance_variable_get(:@files).should == ['foo.html', 'bar.html'] }
  it { 
    @maker.instance_variable_get(:@nav).should == [
        {:label => '1. foo', :content => 'foo.html'},
        {:label => '1. bar', :content => 'bar.html'}
      ]
  }

  it 'should save' do
    stub(FileUtils).cp.with_any_args
    mock(Dir).mktmpdir {|i| i.call('/tmp')}
    mock(EeePub::NCX).new(
      :title => "sample",
      :nav => [
        {:label => '1. foo', :content => 'foo.html'},
        {:label => '1. bar', :content => 'bar.html'}
      ],
      :uid => "http://example.com/book/foo"
    ) { stub!.save }
    mock(EeePub::OPF).new(
      :title => ["sample"],
      :creator => ["jugyo"],
      :date => ["2010-05-06"],
      :language => ['en'],
      :subject => ['epub sample'],
      :description => ['this is epub sample'],
      :rights => ['xxx'],
      :relation => ['xxx'],
      :ncx => "toc.ncx",
      :publisher => ["jugyo.org"],
      :identifier => [{:value => "http://example.com/book/foo", :scheme => "URL"}],
      :manifest => ['foo.html', 'bar.html']
    ) { stub!.save }
    mock(EeePub::OCF).new(
      :container => "content.opf",
      :dir => '/tmp'
    ) { stub!.save }

    @maker.save('test.epub')
  end

  describe "files as hash" do
    before do
      @maker = EeePub::Maker.new do
        title 'sample'
        creator 'jugyo'
        publisher 'jugyo.org'
        date "2010-05-06"
        language 'en'
        subject 'epub sample'
        description 'this is epub sample'
        rights 'xxx'
        relation 'xxx'
        identifier 'http://example.com/book/foo', :scheme => 'URL'
        uid 'http://example.com/book/foo'
        ncx_file 'toc.ncx'
        opf_file 'content.opf'
        files [{'foo.html' => 'foo/bar'}, {'bar.html' => 'foo/bar/baz'}]
        nav [
          {:label => '1. foo', :content => 'foo.html'},
          {:label => '1. bar', :content => 'bar.html'}
        ]
      end
    end

    it 'should save' do
      stub(FileUtils).cp.with_any_args
      stub(FileUtils).mkdir_p.with_any_args
      mock(Dir).mktmpdir {|i| i.call('/tmp')}
      mock(EeePub::NCX).new.with_any_args { stub!.save }
      mock(EeePub::OPF).new(
        :title => ["sample"],
        :creator => ["jugyo"],
        :date => ["2010-05-06"],
        :language => ['en'],
        :subject => ['epub sample'],
        :description => ['this is epub sample'],
        :rights => ['xxx'],
        :relation => ['xxx'],
        :ncx => "toc.ncx",
        :publisher => ["jugyo.org"],
        :identifier => [{:value => "http://example.com/book/foo", :scheme => "URL"}],
        :manifest => ["foo/bar/foo.html", "foo/bar/baz/bar.html"]
      ) { stub!.save }
      mock(EeePub::OCF).new.with_any_args { stub!.save }

      @maker.save('test.epub')
    end
  end
end
