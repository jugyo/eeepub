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
    def container=(arg)
      case arg
      when String
        @container = EeePub::OCF::Container.new(arg)
      else
        @container = arg
      end
    end

    # Save as OCF
    #
    # @param [String] output_path the output file path of ePub
    def save(output_path)
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
