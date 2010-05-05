require 'builder'

module EeePub
  class ContainerItem
    class << self
      def default_value(name, default)
        instance_variable_name = "@#{name}"
        define_method(name) do
          self.instance_variable_get(instance_variable_name) ||
            self.instance_variable_set(instance_variable_name, default)
        end
      end

      def attr_alias(name, src)
        alias_method name, src
        alias_method :"#{name}=", :"#{src}="
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
      out = ""
      builder = Builder::XmlMarkup.new(:target => out, :indent => 2)
      builder.instruct!
      build_xml(builder)
      out
    end

    def save(filepath)
      File.open(filepath, 'w') do |file|
        file << self.to_xml
      end
    end

    def guess_media_type(filename)
      case filename
      when /.*\.html?$/i
        'application/xhtml+xml'
      when /.*\.css$/i
        'text/css'
      when /.*\.(jpeg|jpg)$/
        'image/jpeg'
      when /.*\.png$/i
        'image/png'
      when /.*\.gif$/i
        'image/gif'
      when /.*\.svg$/i
        'image/svg+xml'
      when /.*\.ncx$/i
        'application/x-dtbncx+xml'
      when /.*\.opf$/i
        'application/oebps-package+xml'
      end
    end

    def create_build_option(hash)
      result = {}
      hash.each do |k, v|
        key = k.to_s.gsub('_', '-').to_sym
        result[key] = v
      end
      result
    end
  end
end
