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
                  :ncx,
                  :toc

    default_value :toc, 'ncx'
    default_value :unique_identifier, 'BookId'
    default_value :title, 'Untitled'
    default_value :language, 'en'
    default_value :ncx, 'toc.ncx'

    attr_alias :files, :manifest

    def initialize(values)
      super
    end

    def spine
      unless @spine
        items = manifest.map do |i|
          case i
          when String
            id = i
            media_type = guess_media_type(i)
          when Hash
            id = i[:id]
            media_type = i[:media_type] || guess_media_type(i[:href])
          end
          media_type == 'application/xhtml+xml' ? id : nil
        end
        @spine = items.compact
      end
      @spine
    end

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

        case identifier
        when Array
          identifier.each do |i|
            builder.dc :identifier, i[:value], :id => i[:id], 'opf:scheme' => i[:scheme]
          end
        else
          builder.dc :identifier, identifier[:value], :id => unique_identifier, 'opf:scheme' => identifier[:scheme]
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
      items = manifest + [{:id => 'ncx', :href => ncx}]
      builder.manifest do
        items.each do |i|
          case i
          when Hash
            builder.item :id => i[:id], :href => i[:href], 'media-type' => i[:media_type] || guess_media_type(i[:href])
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
