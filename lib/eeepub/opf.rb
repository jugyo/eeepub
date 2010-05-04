module EeePub
  class OPF < ContainerItem
    attr_accessor :unique_identifier,
                  :title,
                  :language,
                  :identifier,
                  :date,
                  :subject,
                  :description,
                  :relation,
                  :creator,
                  :publisher,
                  :rights,
                  :manifest,
                  :spine,
                  :toc

    def build_xml(builder)
      builder.package :xmlns => "http://www.idpf.org/2007/opf",
          'unique-identifier' => unique_identifier,
          'version' => "2.0" do

        build_metadata(builder)
        build_manifest(builder)
        build_spine(builder)
      end
    end

    def build_metadata(builder)
      builder.metadata 'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
        'xmlns:dcterms' => "http://purl.org/dc/terms/",
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
        'xmlns:opf' => "http://www.idpf.org/2007/opf" do

        [identifier].flatten.each do |i|
          builder.dc :identifier, i[:value], :id => i[:id], 'opf:scheme' => i[:scheme]
        end

        [:title, :language, :subject, :description, :relation, :creator, :publisher, :date, :rights].each do |i|
          value = self.send(i)
          if value
            [value].flatten.each do |v|
              builder.dc i, v
            end
          end
        end
      end
    end

    def build_manifest(builder)
      builder.manifest do
        manifest.each do |i|
          case i
          when Hash
            builder.item create_build_option(i)
          when String
            builder.item :id => i, :href => i, 'media-type' => guess_media_type(i)
          else
            raise 'manifest item must be Hash or String'
          end
        end
      end
    end

    def build_spine(builder)
      builder.spine :toc => toc do
        spine.each do |i|
          builder.itemref :idref => i
        end
      end
    end
  end
end
