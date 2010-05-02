module EeePub
  class NCX < ContainerItem
    template 'ncx.erb'
    attr_accessor :uid,
                  :depth,
                  :total_page_count,
                  :max_page_number,
                  :doc_title,
                  :nav_points

    def set_values(values)
      super
      @depth            ||= 1
      @total_page_count ||= 0
      @max_page_number  ||= 0
    end
  end
end
