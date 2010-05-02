require 'erb'

module EeePub
  class ContainerItem
    include ERB::Util

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
        File.read(File.expand_path("templates/#{filename}", File.dirname(__FILE__))),
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
