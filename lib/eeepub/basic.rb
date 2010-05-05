require 'tmpdir'
require 'fileutils'

module EeePub
  class Basic
    attr_accessor :title, :id, :uid, :files, :nav

    def initialize(values)
      values.each do |k, v|
        self.send(:"#{k}=", v)
      end
      @files ||= []
      @nav ||= []
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
      ).save(File.join(dir, 'toc.ncx'))

      EeePub::OPF.new(
        :title => title,
        :identifier => id,
        :manifest => files.map{|i| File.basename(i)},
        :ncx => 'toc.ncx'
      ).save(File.join(dir, 'content.opf'))

      EeePub::OCF.new(
        :dir => dir,
        :container => 'content.opf'
      ).save(filename)

      FileUtils.rm_rf(dir)
    end
  end
end
