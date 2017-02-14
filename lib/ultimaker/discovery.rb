require "dnssd"
require "ipaddr"
require "ultimaker"

module Ultimaker
  # Discovers all printers on the network. Requires the ultimaker-discovery gem to be installed and required.
  # @see Ultimaker::Discovery.discover_printers
  def self.discover_printers
    Discovery.discover_printers
  end

  # Search for a printer with a specific name. Requires the ultimaker-discovery gem to be installed and required.
  # @see Ultimaker::Discovery.find_by_name
  def self.find_by_name(name)
    Discovery.find_by_name(name)
  end

  # Ultimaker::Discovery is for discovering Ultimaker printers on your network via mDNS. Requires the
  # ultimaker-discovery gem to be installed and required.
  module Discovery
    # @!visibility private
    TIMEOUT = 2

    # @!visibility private
    TYPE = "_ultimaker._tcp".freeze

    # Represents a discovered printer and holds basic info collected during the discovery process.
    class Printer
      # The IP address of the printer.
      # @return [IPAddr]
      attr_reader :address

      # A hash containing all of the extra information collected.
      # @return [Hash]
      attr_reader :extra

      # The firmware version of the printer.
      # @return [String]
      attr_reader :firmware_version

      # The hostname of the printer.
      # @return [String]
      attr_reader :hostname

      # The name of the printer.
      # @return [String]
      attr_reader :name

      # Type code of the printer.
      # * Starts with 9066 for the Ultimaker 3.
      # * Starts with 9511 for the Ultimaker 3 Extended.
      # @return [String]
      attr_reader :type

      # @!visibility private
      def initialize(addr_info, text_record)
        @address = IPAddr.new(addr_info.address).freeze
        @extra = text_record.reject { |key,| %W[firmware_version machine name type].include?(key) }.freeze
        @firmware_version = text_record["firmware_version"].freeze
        @hostname = addr_info.hostname.freeze
        @name = text_record["name"].freeze
        @type = text_record["machine"].freeze
      end

      # Connects to the discovered printer using the full fledged Ultimaker API.
      # @return [Ultimaker::Printer] The full fledged printer.
      def connect
        klass = Ultimaker::TYPES[type.split(".").first]
        klass.new()
      end
    end

    # Discovers all printers on the network.
    # @return [Array<Printer>] The printers that were discovered.
    def self.discover_printers
      service = DNSSD::Service.browse(TYPE)
      service.each(TIMEOUT).map do |browse_reply|
        resolve_reply = resolve(browse_reply)

        Printer.new(get_address(resolve_reply), resolve_reply.text_record)
      end
    ensure
      service.stop
    end

    # Search for a printer with a specific name.
    # @param name [String] The name of the printer to search for.
    # @return [Printer, nil] The printer or nil.
    def self.find_by_name(name)
      service = DNSSD::Service.browse(TYPE)
      service.each(TIMEOUT).each do |browse_reply|
        resolve_reply = resolve(browse_reply)

        if resolve_reply.text_record["name"] == name
          return Printer.new(get_address(resolve_reply), resolve_reply.text_record)
        end
      end

      nil
    ensure
      service.stop
    end

    private
    def self.get_address(reply)
      service = DNSSD::Service.getaddrinfo(reply.target, 0, 0, reply.interface)
      service.each(TIMEOUT).detect { |addr_info| !addr_info.flags.more_coming? }
    ensure
      service.stop
    end

    def self.resolve(reply)
      service = DNSSD::Service.resolve(reply)
      service.each(TIMEOUT).detect { |resolved| !resolved.flags.more_coming? }
    ensure
      service.stop
    end
  end
end
