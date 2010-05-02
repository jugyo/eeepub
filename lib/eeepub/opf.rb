module EeePub
  class OPF < ContainerItem
    template 'opf.erb'
    attr_accessor :title,
                  :language,
                  :identifier,
                  :date,
                  :subject,
                  :description,
                  :relation,
                  :creator,
                  :publisher,
                  :rights,
                  :items,
                  :itemrefs
  end
end
