$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rubygems'
require 'eeepub'

dir = File.join(File.dirname(__FILE__), 'files')

epub = EeePub::Basic.new(
  :title => 'sample',
  :creator => 'jugyo',
  :publisher => 'jugyo.org',
  :date => "2010-05-06",
  :id => {'URL' => 'http://example.com/book/foo'},
  :uid => 'http://example.com/book/foo'
)
epub.files << File.join(dir, 'foo.html')
epub.files << File.join(dir, 'bar.html')
epub.nav << {:label => '1. foo', :content => 'foo.html'}
epub.nav << {:label => '2. bar', :content => 'bar.html'}
epub.save('sample.epub')

puts "complete! => 'sample.epub'"
