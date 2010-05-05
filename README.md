EeePub
======

EeePub is a Ruby ePub generator.

Usage
-------

### Basic

    epub = EeePub::Basic.new(
      :title => 'simple',
      :creator => 'jugyo',
      :publisher => 'jugyo.org',
      :date => "2010-05-06",
      :id => {'URL' => 'http://example.com/book/foo'},
      :uid => 'http://example.com/book/foo'
    )
    epub.files << '/path/to/foo.html'
    epub.files << '/path/to/bar.html'
    epub.nav << {:label => '1. foo', :content => 'foo.html'}
    epub.nav << {:label => '2. bar', :content => 'bar.html'}
    epub.save('sample.epub')

### Raw

Create NCX:

    EeePub::NCX.new(
      :uid => 'xxxx',
      :title => 'sample',
      :nav => [
        {:label => '1. foo', :content => 'foo.html'},
        {:label => '2. bar', :content => 'bar.html'}
      ]
    ).save(File.join('sample', 'toc.ncx'))

Create OPF:

    EeePub::OPF.new(
      :title => 'sample',
      :identifier => {'ISBN' => '0-0000000-0-0'},
      :manifest => ['foo.html', 'bar.html'],
      :ncx => 'toc.ncx'
    ).save(File.join('sample', 'content.opf'))

Create OCF and ePub file:

    EeePub::OCF.new(
      :dir => 'sample',
      :container => 'content.opf'
    ).save('sample.epub')

Install
-------

    gem install eeepub

Copyright
-------

Copyright (c) 2010 jugyo. See LICENSE for details.
