require 'zipruby'

module EeePub
  # Class to create OCF
  class OCF
    # Class for 'container.xml' of OCF
    class Container < ContainerItem
      attr_accessor :rootfiles

      # @param [String or Array or Hash]
      #
      # @example
      #   # with String
      #   EeePub::OCF::Container.new('container.opf')
      #
      # @example
      #   # with Array
      #   EeePub::OCF::Container.new(['container.opf', 'other.opf'])
      #
      # @example
      #   # with Hash
      #   EeePub::OCF::Container.new(
      #     :rootfiles => [
      #       {:full_path => 'container.opf', :media_type => 'application/oebps-package+xml'}
      #     ]
      #   )
      def initialize(arg)
        case arg
        when String
          set_values(
            :rootfiles => [
              {:full_path => arg, :media_type => guess_media_type(arg)}
            ]
          )
        when Array
          # TODO: spec
          set_values(
            :rootfiles => arg.keys.map { |k|
              filename = arg[k]
              {:full_path => filename, :media_type => guess_media_type(filename)}
            }
          )
        when Hash
          set_values(arg)
        end
      end

      private

      def build_xml(builder)
        builder.container :xmlns => "urn:oasis:names:tc:opendocument:xmlns:container", :version => "1.0" do
          builder.rootfiles do
            rootfiles.each do |i|
              builder.rootfile convert_to_xml_attributes(i)
            end
          end
        end
      end
    end

    attr_accessor :dir, :container

    # @param [Hash<Symbol, Object>] values the values of symbols and objects for OCF
    #
    # @example
    #   EeePub::OCF.new(
    #     :dir => '/path/to/dir',
    #     :container => 'container.opf'
    #   )
    def initialize(values)
      values.each do |k, v|
        self.send(:"#{k}=", v)
      end
    end

    # Set container
    #
    # @param [EeePub::OCF::Container or args for EeePub::OCF::Container]
    def container=(arg)
      if arg.is_a?(EeePub::OCF::Container)
        @container = arg
      else
        # TODO: spec
        @container = EeePub::OCF::Container.new(arg)
      end
    end

    # Save as OCF
    #
    # @param [String] output_path the output file path of ePub
    def save(output_path)
      output_path = File.expand_path(output_path)

      create_epub do
        Zip::Archive.open(output_path, Zip::CREATE | Zip::TRUNC) do |zip|
          Dir.glob('**/*').each do |path|
            if File.directory?(path)
              zip.add_dir(path)
            else
              zip.add_file(path, path)
            end
          end
        end
      end
    end
    
    # Stream OCF
    #
    # @return [String] streaming output of the zip/epub file.
    def render
      create_epub do
        buffer = Zip::Archive.open_buffer(Zip::CREATE) do |zip|
          Dir.glob('**/*').each do |path|
            if File.directory?(path)
              zip.add_dir(path)
            else
              zip.add_file(path, path)
            end
          end
        end

        return buffer
      end
    end

    private
    def create_epub
      FileUtils.chdir(dir) do
        File.open('mimetype', 'w') do |f|
          f << 'application/epub+zip'
        end

        meta_inf = 'META-INF'
        FileUtils.mkdir_p(meta_inf)

        container.save(File.join(meta_inf, 'container.xml'))
        yield
      end

    end
  end
end
