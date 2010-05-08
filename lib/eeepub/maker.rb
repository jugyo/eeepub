module EeePub
  class Maker
    [
      :title,
      :creator,
      :publisher,
      :date,
      :identifier,
      :uid,
      :files,
      :nav,
      :ncx_file,
      :opf_file
    ].each do |name|
      define_method(name) do |*arg|
        iv_name = "@#{name}"
        unless instance_variable_defined?(iv_name)
          instance_variable_set(iv_name, [])
        end
        value = arg.size == 1 ? arg[0] : arg
        instance_variable_get(iv_name) << value
      end
    end

    def initialize(&block)
      @files ||= []
      @nav ||= []
      @ncx_file ||= 'toc.ncx'
      @opf_file ||= 'content.opf'

      instance_eval(&block)
    end

    def save(filename)
      Dir.mktmpdir do |dir|
        files.each do |file|
          FileUtils.cp(file, dir)
        end

        EeePub::NCX.new(
          :uid => @uid,
          :title => @title,
          :nav => @nav
        ).save(File.join(dir, @ncx_file))

        EeePub::OPF.new(
          :title => @title,
          :identifier => @identifier,
          :creator => @creator,
          :publisher => @publisher,
          :date => @date,
          :manifest => @files.map{|i| File.basename(i)},
          :ncx => @ncx_file
        ).save(File.join(dir, @opf_file))

        EeePub::OCF.new(
          :dir => dir,
          :container => @opf_file
        ).save(filename)
      end
    end
  end
end
