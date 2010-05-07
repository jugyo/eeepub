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
                  :guide,
                  :ncx,
                  :toc

    default_value :toc, 'ncx'
    default_value :unique_identifier, 'BookId'
    default_value :title, 'Untitled'
    default_value :language, 'en'

    attr_alias :files, :manifest

    def identifier
      case @identifier
      when Array
        @identifier
      when String
        [{:value => @identifier, :id => unique_identifier}]
      when Hash
        @identifier[:id] = unique_identifier
        [@identifier]
      else
        @identifier
      end
    end

    def spine
      @spine ||
        complete_manifest.
          select { |i| i[:media_type] == 'application/xhtml+xml' }.
          map { |i| i[:id]}
    end

    def build_xml(builder)
      builder.package :xmlns => "http://www.idpf.org/2007/opf",
          'unique-identifier' => unique_identifier,
          'version' => "2.0" do

        build_metadata(builder)
        build_manifest(builder)
        build_spine(builder)
        build_guide(builder)
      end
    end

    def build_metadata(builder)
      builder.metadata 'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
        'xmlns:dcterms' => "http://purl.org/dc/terms/",
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
        'xmlns:opf' => "http://www.idpf.org/2007/opf" do

        identifier.each do |i|
          attrs = {}
          attrs['opf:scheme'] = i[:scheme] if i[:scheme]
          attrs[:id] = i[:id] if i[:id]
          builder.dc :identifier, i[:value], attrs
        end

        [:title, :language, :subject, :description, :relation, :creator, :publisher, :date, :rights].each do |i|
          value = self.send(i)
          next unless value

          [value].flatten.each do |v|
            case v
            when Hash
              builder.dc i, v[:value], convert_to_xml_attributes(v.reject {|k, v| k == :value})
            else
              builder.dc i, v
            end
          end
        end
      end
    end

    def build_manifest(builder)
      builder.manifest do
        complete_manifest.each do |i|
          builder.item :id => i[:id], :href => i[:href], 'media-type' => i[:media_type]
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

    def build_guide(builder)
      return if guide.nil? || guide.empty?

      builder.guide do
        guide.each do |i|
          builder.reference convert_to_xml_attributes(i)
        end
      end
    end

    def complete_manifest
      item_id_cache = {}

      result = manifest.map do |i|
        case i
        when String
          id = create_unique_item_id(i, item_id_cache)
          href = i
          media_type = guess_media_type(i)
        when Hash
          id = i[:id] || create_unique_item_id(i[:href], item_id_cache)
          href = i[:href]
          media_type = i[:media_type] || guess_media_type(i[:href])
        end
        {:id => id, :href => href, :media_type => media_type}
      end

      result += [{:id => 'ncx', :href => ncx, :media_type => 'application/x-dtbncx+xml'}] if ncx
      result
    end

    def create_unique_item_id(filename, id_cache)
      basename = File.basename(filename)
      unless id_cache[basename]
        id_cache[basename] = 0
        name = basename
      else
        name = "#{basename}-#{id_cache[basename]}"
      end
      id_cache[basename] += 1
      name
    end
  end
end
