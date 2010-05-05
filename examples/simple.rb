$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rubygems'
require 'eeepub'
require 'fileutils'

dir = 'simple'
FileUtils.rm_rf(dir)
FileUtils.mkdir(dir)

epub_name = 'simple.epub'
FileUtils.rm_f(epub_name)

# Create sample html
['foo', 'bar'].each do |name|
  File.open(File.join(dir, "#{name}.html"), 'w') do |f|
    f << <<-HTML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja">
  <head>
    <title></title>
  </head>
  <body>
    <h1>#{name}</h1>
  </body>
</html>
    HTML
  end
end

# Create NCX
EeePub::NCX.new(
  :uid => 'xxxx',
  :title => 'simple',
  :nav => [
    {:label => '1. foo', :content => 'foo.html'},
    {:label => '2. bar', :content => 'bar.html'}
  ]
).save(File.join(dir, 'toc.ncx'))

# Create OPF
EeePub::OPF.new(
  :title => 'simple',
  :identifier => {'ISBN' => '0-0000000-0-0'},
  :manifest => ['foo.html', 'bar.html'],
  :ncx => 'toc.ncx'
).save(File.join(dir, 'content.opf'))

# Create OCF
EeePub::OCF.new(
  :dir => dir,
  :container => 'content.opf'
).make(epub_name)
