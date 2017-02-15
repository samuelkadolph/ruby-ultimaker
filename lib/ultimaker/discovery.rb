require "dnssd"
require "ultimaker"

module Ultimaker
  class << self
    # Discovers all printers on the network. Requires the ultimaker-discovery gem to be installed and required.
    # @return [Array<Printer>] The printers that were discovered.
    # @see Ultimaker::Discovery.discover_printers
    def discover_printers
      Discovery.discover_printers
    end

    # Search for a printer with a specific name. Requires the ultimaker-discovery gem to be installed and required.
    # @param name [String] The name of the printer to search for.
    # @return [Printer, nil] The printer or nil.
    # @see Ultimaker::Discovery.find_by_name
    def find_by_name(name)
      Discovery.find_by_name(name)
    end

    # Search for a printer with a specific name and raise an error if it is not found. Requires the ultimaker-discovery
    # gem to be installed and required.
    # @param name [String] The name of the printer to search for.
    # @return [Printer] The printer.
    # @raise [PrinterNotFoundError] If the printer is not found.
    # @see Ultimaker::Discovery.find_by_name!
    def find_by_name!(name)
      Discovery.find_by_name!(name)
    end
  end

  # Ultimaker::Discovery is for discovering Ultimaker printers on your network via mDNS. Requires the
  # ultimaker-discovery gem to be installed and required.
  module Discovery
    # @!visibility private
    MDNS_TIMEOUT = 2

    # @!visibility private
    MDNS_TYPE = "_ultimaker._tcp".freeze

    # Represents a discovered printer and holds basic info collected during the discovery process.
    class Printer
      # The IP address of the printer.
      # @return [String]
      attr_reader :address

      # A hash containing all of the extra information collected. Examples: +hotend_serial_0+, +hotend_type_0+.
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
        scrubbed = Hash[text_record.map { |k, v| [k, v.force_encoding("UTF-8").freeze] }]

        @address = addr_info.address.freeze
        @extra = scrubbed.reject { |key,| %W[firmware_version machine name type].include?(key) }.freeze
        @firmware_version = scrubbed["firmware_version"]
        @hostname = addr_info.hostname.freeze
        @name = scrubbed["name"]
        @type = scrubbed["machine"]
      end

      # Connects to the discovered printer using the full fledged Ultimaker API.
      # @return [Ultimaker::Printer] The full fledged printer.
      def connect
        klass = Ultimaker::TYPES[type.split(".").first]
        klass.new()
      end
    end

    class << self
      # Discovers all printers on the network.
      # @return [Array<Printer>] The printers that were discovered.
      def discover_printers
        service = DNSSD::Service.browse(self::MDNS_TYPE)
        service.each(self::MDNS_TIMEOUT).map do |browse_reply|
          resolve_reply = resolve(browse_reply)

          Printer.new(get_address(resolve_reply), resolve_reply.text_record)
        end
      ensure
        service.stop
      end

      # Search for a printer with a specific name.
      # @param name [String] The name of the printer to search for.
      # @return [Printer, nil] The printer or nil.
      def find_by_name(name)
        service = DNSSD::Service.browse(self::MDNS_TYPE)
        service.each(self::MDNS_TIMEOUT).each do |browse_reply|
          resolve_reply = resolve(browse_reply)

          if resolve_reply.text_record["name"] == name
            return Printer.new(get_address(resolve_reply), resolve_reply.text_record)
          end
        end

        nil
      ensure
        service.stop if service
      end

      # Search for a printer with a specific name and raise an error if it is not found.
      # @param name [String] The name of the printer to search for.
      # @return [Printer] The printer.
      # @raise [PrinterNotFoundError] If the printer is not found.
      def find_by_name!(name)
        find_by_name(name) || raise(PrinterNotFoundError, "Could not find a printer with name '#{name}'")
      end

      private
      def get_address(reply)
        service = DNSSD::Service.getaddrinfo(reply.target, 0, 0, reply.interface)
        service.each(self::MDNS_TIMEOUT).detect { |addr_info| !addr_info.flags.more_coming? }
      ensure
        service.stop if service
      end

      def resolve(reply)
        service = DNSSD::Service.resolve(reply)
        service.each(self::MDNS_TIMEOUT).detect { |resolved| !resolved.flags.more_coming? }
      ensure
        service.stop if service
      end
    end
  end
end
