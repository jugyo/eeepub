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
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja">
  <body>
    <h1>#{name}</h1>
  </body>
</html>
    HTML
  end
end

# Create NCX
EeePub::NCX.new(
  :uid => 'xxxx', :doc_title => 'simple',
  :nav_points => [
    {:id => 'nav-1', :play_order => '1', :label => '1. foo', :content => 'foo.html'},
    {:id => 'nav-2', :play_order => '2', :label => '2. bar', :content => 'bar.html'}
  ]
).save(File.join(dir, 'toc.ncx'))

# Create OPF
EeePub::OPF.new(
  :title => 'simple',
  :language => 'ja',
  :identifier => 'xxxxxxx',
  :items => [
    {:id => 'ncx', :href => 'toc.ncx', :media_type => 'text/xml'},
    {:id => 'foo', :href => 'foo.html', :media_type => 'text/html'},
    {:id => 'bar', :href => 'bar.html', :media_type => 'text/html'},
  ],
  :itemrefs => [
    {:idref => 'foo'},
    {:idref => 'bar'}
  ]
).save(File.join(dir, 'package.opf'))

# Create OCF
EeePub::OCF.new(
  :dir => dir,
  :container => EeePub::OCF::Container.new(
    :rootfiles => [
      {:full_path => 'package.opf', :media_type => 'application/oebps-package+xml'}
    ]
  )
).make(epub_name)
