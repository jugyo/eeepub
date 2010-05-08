EeePub
======

EeePub is a Ruby ePub generator.

Note
-------

I am thinking more better API now...

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
      :identifier => {:value => '0-0000000-0-0', :scheme => 'ISBN'},
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

Requirements
-------

* ruby 1.8.7
* builder
* eBook Reader :)

Links
-------

* Documentation: [http://yardoc.org/docs/jugyo-eeepub](http://yardoc.org/docs/jugyo-eeepub)
* Source code: [http://github.com/jugyo/eeepub](http://github.com/jugyo/eeepub)

Copyright
-------

Copyright (c) 2010 jugyo. See LICENSE for details.
