module EeePub
  class OCF
    class Container < ContainerItem
      template 'container.xml.erb'
      attr_accessor :rootfiles
    end

    attr_accessor :dir, :container

    def initialize(dir, contents)
      @dir = dir
      contents.each do |k, v|
        self.send(:"#{k}=", v)
      end
    end

    def make(output_path)
      FileUtils.chdir(dir) do
        File.open('mimetype', 'w') do |f|
          f << 'application/epub+zip'
        end

        meta_inf = 'META-INF'
        FileUtils.mkdir_p(meta_inf)

        container.save(File.join(meta_inf, 'container.xml'))

        %x(zip -X9 \"#{output_path}\" mimetype)
        %x(zip -Xr9D \"#{output_path}\" * -xi mimetype)
      end
    end
  end
end
