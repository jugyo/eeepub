$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rubygems'
require 'eeepub'

dir = File.join(File.dirname(__FILE__), 'files')

epub = EeePub.make do
  title       'sample'
  creator     'jugyo'
  publisher   'jugyo.org'
  date        '2010-05-06'
  identifier  'http://example.com/book/foo', :scheme => 'URL'
  uid         'http://example.com/book/foo'

  files [File.join(dir, 'foo.html'), File.join(dir, 'bar.html')]
  nav [
    {:label => '1. foo', :content => 'foo.html', :nav => [
      {:label => '1.1 foo-1', :content => 'foo.html#foo-1'}
    ]},
    {:label => '1. bar', :content => 'bar.html'}
  ]
end
epub.save('sample.epub')

puts "complete! => 'sample.epub'"
