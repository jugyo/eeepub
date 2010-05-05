require 'tmpdir'
require 'fileutils'

module EeePub
  class Basic
    attr_accessor :title, :creator, :publisher, :date, :id, :uid, :files, :nav, :ncx_file, :opf_file

    def initialize(values)
      values.each do |k, v|
        self.send(:"#{k}=", v)
      end
      @files ||= []
      @nav ||= []
      @ncx_file ||= 'toc.ncx'
      @opf_file ||= 'content.opf'
    end

    def save(filename)
      dir = Dir.mktmpdir

      files.each do |file|
        FileUtils.cp(file, dir)
      end

      EeePub::NCX.new(
        :uid => uid,
        :title => title,
        :nav => nav
      ).save(File.join(dir, ncx_file))

      EeePub::OPF.new(
        :title => title,
        :identifier => id,
        :creator => creator,
        :publisher => publisher,
        :date => date,
        :manifest => files.map{|i| File.basename(i)},
        :ncx => ncx_file
      ).save(File.join(dir, opf_file))

      EeePub::OCF.new(
        :dir => dir,
        :container => opf_file
      ).save(filename)

      FileUtils.rm_rf(dir)
    end
  end
end
