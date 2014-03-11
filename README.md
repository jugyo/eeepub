EeePub
======

EeePub is a Ruby ePub generator.  This is a version of the eepub project from https://github.com/jugyo/eeepub, and had been modified to suit Inkshares' needs.  Main enhancements include:

- Compatibility with Ruby 2.0
- Compatibility with the latest version of Rubyzip (required to bundle epub files)
- Support for the 'guide' ocf attribute, which allows an ebook maker to specify an HTML page for the book cover.
- Passing unit tests

Also of note, this project does not produce .mobi files for Kindle.  But, we recommend a very excellent service called Ebook Glue, https://ebookglue.com/, which provides an affordable API to convert .epub into .mobi files.

Usage
-------

    epub = EeePub.make do
      title       'sample'
      creator     'jugyo'
      publisher   'jugyo.org'
      date        '2010-05-06'
      identifier  'http://example.com/book/foo', :scheme => 'URL'
      uid         'http://example.com/book/foo'

      files ['/path/to/foo.html', '/path/to/bar.html'] # or files [{'/path/to/foo.html' => 'dest/dir'}, {'/path/to/bar.html' => 'dest/dir'}]
      nav [
        {:label => '1. foo', :content => 'foo.html', :nav => [
          {:label => '1.1 foo-1', :content => 'foo.html#foo-1'}
        ]},
        {:label => '1. bar', :content => 'bar.html'}
      ]
    end
    epub.save('sample.epub')

### Low Level API

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

* builder
* eBook Reader :)

Links
-------

* Documentation: [http://yardoc.org/docs/jugyo-eeepub](http://yardoc.org/docs/jugyo-eeepub)
* Source code: [http://github.com/inkshares/eeepub](http://github.com/inkshares/eeepub)

Copyright
-------

Copyright (c) 2014 Inkshares. See LICENSE for details.
