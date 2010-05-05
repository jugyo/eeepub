module EeePub
  class NCX < ContainerItem
    attr_accessor :uid,
                  :depth,
                  :total_page_count,
                  :max_page_number,
                  :doc_title,
                  :nav_map

    attr_alias :title, :doc_title
    attr_alias :nav, :nav_map

    default_value :depth, 1
    default_value :total_page_count, 0
    default_value :max_page_number, 0
    default_value :doc_title, 'Untitled'

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
        builder_nav_point(builder, nav_map)
      end
    end

    def builder_nav_point(builder, nav_point, play_order = 1)
      case nav_point
      when Array
        nav_point.each do |point|
          play_order = builder_nav_point(builder, point, play_order)
        end
      when Hash
        id = nav_point[:id] || "navPoint-#{play_order}"
        builder.navPoint :id => id, :playOrder => play_order do
          builder.navLabel { builder.text nav_point[:label] }
          builder.content :src => nav_point[:content]
          play_order += 1
          if nav_point[:nav]
            play_order = builder_nav_point(builder, nav_point[:nav], play_order)
          end
        end
      else
        raise "nav_point must be Array or Hash"
      end
      play_order
    end
  end
end
