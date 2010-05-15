require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "EeePub::Easy" do
  before do
    @easy = EeePub::Easy.new do
      title 'sample'
      creator 'jugyo'
      identifier 'http://example.com/book/foo', :scheme => 'URL'
      uid 'http://example.com/book/foo'
    end

    @easy.sections << ['1. foo', <<HTML]
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja">
  <head>
    <title>foo</title>
  </head>
  <body>
    <p>
    foo foo foo foo foo foo
    </p>
  </body>
</html>
HTML

    @easy.sections << ['2. bar', <<HTML]
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja">
  <head>
    <title>bar</title>
  </head>
  <body>
    <p>
    bar bar bar bar bar bar
    </p>
  </body>
</html>
HTML

    @easy.assets << 'image.png'
  end

  it 'spec for prepare' do
    Dir.mktmpdir do |dir|
      mock(FileUtils).cp('image.png', dir)

      @easy.send(:prepare, dir)

      file1 = File.join(dir, 'section_0.html')
      file2 = File.join(dir, 'section_1.html')
      File.exists?(file1).should be_true
      File.exists?(file2).should be_true
      File.read(file1).should == @easy.sections[0][1]
      File.read(file2).should == @easy.sections[1][1]

      @easy.instance_variable_get(:@nav).should == [
        {:label => '1. foo', :content => 'section_0.html'},
        {:label => '2. bar', :content => 'section_1.html'}
      ]

      @easy.instance_variable_get(:@files).should == [file1, file2, 'image.png']
    end
  end
end
