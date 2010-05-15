require 'tmpdir'
require 'fileutils'

module EeePub
  # The class to make ePub more easily
  #
  # @example
  #   epub = EeePub::Easy.new do
  #     title 'sample'
  #     creator 'jugyo'
  #     identifier 'http://example.com/book/foo', :scheme => 'URL'
  #     uid 'http://example.com/book/foo'
  #   end
  #   
  #   epub.sections << ['1. foo', <<HTML]
  #   <?xml version="1.0" encoding="UTF-8"?>
  #   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
  #   <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja">
  #     <head>
  #       <title>foo</title>
  #     </head>
  #     <body>
  #       <p>
  #       foo foo foo foo foo foo
  #       </p>
  #     </body>
  #   </html>
  #   HTML
  #   
  #   epub.assets << 'image.png'
  #   
  #   epub.save('sample.epub')
  class Easy < EeePub::Maker
    attr_reader :sections, :assets

    # @param [Proc] block the block for initialize
    def initialize(&block)
      @sections = []
      @assets = []
      super
    end

    # Save as ePub file
    #
    # @param [String] filename the ePub file name to save
    def save(filename)
      Dir.mktmpdir do |dir|
        prepare(dir)

        NCX.new(
          :uid => @uid,
          :title => @titles[0],
          :nav => @nav
        ).save(File.join(dir, @ncx_file))

        OPF.new(
          :title => @titles,
          :identifier => @identifiers,
          :creator => @creators,
          :publisher => @publishers,
          :date => @dates,
          :language => @languages,
          :subject => @subjects,
          :description => @descriptions,
          :rights => @rightss,
          :relation => @relations,
          :manifest => @files.map{|i| File.basename(i)},
          :ncx => @ncx_file
        ).save(File.join(dir, @opf_file))

        OCF.new(
          :dir => dir,
          :container => @opf_file
        ).save(filename)
      end
    end

    private

    def prepare(dir)
      filenames = []
      sections.each_with_index do |section, index|
        filename = File.join(dir, "section_#{index}.html")
        File.open(filename, 'w') { |file| file.write section[1] }
        filenames << filename
      end

      assets.each do |file|
        FileUtils.cp(file, dir)
      end

      files(filenames + assets)
      nav(
        [sections, filenames].transpose.map do |section, filename|
          {:label => section[0], :content => File.basename(filename)}
        end
      )
    end
  end
end
