require 'zip/zip'

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
        mimetype = Zip::ZipOutputStream::open(output_path) do |os|
          os.put_next_entry("mimetype", nil, nil, Zip::ZipEntry::STORED, Zlib::NO_COMPRESSION)
          os << "application/epub+zip"
        end
        zipfile = Zip::ZipFile.open(output_path)
        Dir.glob('**/*').each do |path|
          puts path
          puts "READABLE: #{File.readable?(path)}"
          puts "SIZE: #{File.size(path)}"
          zipfile.add(path, path)
        end
        zipfile.commit
      end
      FileUtils.remove_entry_secure dir
    end
    
    # Stream OCF
    #
    # @return [String] streaming output of the zip/epub file.
    def render
      create_epub do
        temp_file = Tempfile.new("ocf")
        self.save(temp_file.path)
        return temp_file.read
      end
    end

    private
    def create_epub
      FileUtils.chdir(dir) do
        meta_inf = 'META-INF'
        FileUtils.mkdir_p(meta_inf)

        container.save(File.join(meta_inf, 'container.xml'))
        yield
      end

    end
  end
end
