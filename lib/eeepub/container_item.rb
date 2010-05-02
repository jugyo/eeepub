require 'erb'

module EeePub
  class ContainerItem
    include ERB::Util

    TEMPLATE_DIR = File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

    class << self
      attr_reader :template_name

      def template(name)
        @template_name = name
      end
    end

    def initialize(values)
      set_values(values)
    end

    def set_values(values)
      values.each do |k, v|
        self.send(:"#{k}=", v)
      end
    end

    def to_xml
      erb(self.class.template_name).result(binding)
    end

    def erb(filename)
      ERB.new(
        File.read(File.join(TEMPLATE_DIR, filename)),
        nil,
        '-'
      )
    end

    def save(filepath)
      File.open(filepath, 'w') do |file|
        file << self.to_xml
      end
    end
  end
end
