module EeePub
  class OCF
    class Container < ContainerItem
      attr_accessor :rootfiles

      def build_xml(builder)
        builder.container :xmlns => "urn:oasis:names:tc:opendocument:xmlns:container", :version => "1.0" do
          builder.rootfiles do
            rootfiles.each do |i|
              builder.rootfile create_build_option(i)
            end
          end
        end
      end
    end

    attr_accessor :dir, :container

    def initialize(values)
      values.each do |k, v|
        self.send(:"#{k}=", v)
      end
    end

    def make(output_path)
      output_path = File.expand_path(output_path)

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
