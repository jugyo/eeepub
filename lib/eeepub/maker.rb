require 'tmpdir'
require 'fileutils'

module EeePub
  # The class to make ePub easily
  #
  # @example
  #   epub = EeePub.make do
  #     title       'sample'
  #     creator     'jugyo'
  #     publisher   'jugyo.org'
  #     date        '2010-05-06'
  #     identifier  'http://example.com/book/foo', :scheme => 'URL'
  #     uid         'http://example.com/book/foo'
  #
  #     files ['/path/to/foo.html', '/path/to/bar.html']
  #     nav [
  #       {:label => '1. foo', :content => 'foo.html', :nav => [
  #         {:label => '1.1 foo-1', :content => 'foo.html#foo-1'}
  #       ]},
  #       {:label => '1. bar', :content => 'bar.html'}
  #     ]
  #   end
  #   epub.save('sample.epub')
  class Maker
    [
      :title,
      :creator,
      :publisher,
      :date,
    ].each do |name|
      class_eval <<-DELIM
        def #{name}(value)
          @#{name}s ||= []
          @#{name}s << value
        end
      DELIM
    end

    [
      :uid,
      :files,
      :nav,
      :ncx_file,
      :opf_file
    ].each do |name|
      define_method(name) do |arg|
        instance_variable_set("@#{name}", arg)
      end
    end

    def identifier(id, options)
      @identifiers ||= []
      @identifiers << {:value => id, :scheme => options[:scheme]}
    end

    # @param [Proc] block the block for initialize
    def initialize(&block)
      @files ||= []
      @nav ||= []
      @ncx_file ||= 'toc.ncx'
      @opf_file ||= 'content.opf'

      instance_eval(&block) if block_given?
    end

    # Save as ePub file
    #
    # @param [String] filename the ePub file name to save
    def save(filename)
      Dir.mktmpdir do |dir|
        @files.each do |file|
          FileUtils.cp(file, dir)
        end

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
          :manifest => @files.map{|i| File.basename(i)},
          :ncx => @ncx_file
        ).save(File.join(dir, @opf_file))

        OCF.new(
          :dir => dir,
          :container => @opf_file
        ).save(filename)
      end
    end
  end
end
