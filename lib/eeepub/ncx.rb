module EeePub
  class NCX < ContainerItem
    attr_accessor :uid,
                  :depth,
                  :total_page_count,
                  :max_page_number,
                  :doc_title,
                  :nav_map

    def set_values(values)
      super
      @depth            ||= 1
      @total_page_count ||= 0
      @max_page_number  ||= 0
    end

    def build_xml(builder)
      builder.declare! :DOCTYPE, :ncx, :PUBLIC, "-//NISO//DTD ncx 2005-1//EN", "http://www.daisy.org/z3986/2005/ncx-2005-1.dtd"
      builder.ncx :xmlns => "http://www.daisy.org/z3986/2005/ncx/", :version => "2005-1" do
        build_head(builder)
        builder.docTitle { builder.text doc_title }
        build_nav_map(builder)
      end
    end

    def build_head(builder)
      builder.head do
        {
          :uid => uid,
          :depth => depth,
          :totalPageCount => total_page_count,
          :maxPageNumber => max_page_number
        }.each do |k, v|
          builder.meta :name => "dtb:#{k}", :content => v
        end
      end
    end

    def build_nav_map(builder)
      builder.navMap do
        nav_map.each do |i|
          builder.navPoint :id => i[:id], :playOrder => i[:play_order] do
            builder.navLabel { builder.text i[:label] }
            builder.content :src => i[:content]
          end
        end
      end
    end
  end
end
