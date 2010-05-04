require 'erb' # TODO 消す
require 'builder'

module EeePub
  class ContainerItem
    include ERB::Util

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
