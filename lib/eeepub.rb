require 'eeepub/version'
require 'eeepub/container_item'
require 'eeepub/opf'
require 'eeepub/ocf'
require 'eeepub/ncx'
require 'eeepub/maker'
require 'eeepub/easy'

module EeePub
  # Make ePub
  #
  # @param [Proc] block the block for initialize EeePub::Maker
  def self.make(&block)
    EeePub::Maker.new(&block)
  end
end
