require "test_helper"
require "securerandom"

class UltimakerDiscoveryTest < Minitest::Test
  def setup
    @browse_replies = []

    DNSSD::Service.stubs(:browse).with("_ultimaker._tcp").returns(stub_service(@browse_replies))
    DNSSD::Service.stubs(:resolve).raises("DNSSD::Service.resolve called with no printers stubbed")
    DNSSD::Service.stubs(:getaddrinfo).raises("DNSSD::Service.getaddrinfo called with no printers stubbed")
  end

  def test_discover_no_printers
    assert_empty Ultimaker::Discovery.discover_printers
  end

  def test_discover_printers_with_one_printer
    stub_printer(ip: "192.168.2.2", serial: "deadbeef0001")

    printers = Ultimaker::Discovery.discover_printers

    assert_equal 1, printers.count
    assert_equal "192.168.2.2", printers[0].address
    assert_equal "ultimakersystem-deadbeef0001", printers[0].hostname
    assert_equal "3.5.3.20161221", printers[0].firmware_version
    assert_equal "ultimaker3", printers[0].name
    assert_equal "9511.0", printers[0].type
    assert_equal "28a7d22effaf", printers[0].extra["hotend_serial_0"]
    assert_equal "b397cb6681c0", printers[0].extra["hotend_serial_1"]
    assert_equal "AA 0.4", printers[0].extra["hotend_type_0"]
    assert_equal "BB 0.4", printers[0].extra["hotend_type_1"]
  end

  def test_discover_printers_with_multiple_printers
    stub_printer(name: "deadbeef1")
    stub_printer(name: "deadbeef2")

    printers = Ultimaker::Discovery.discover_printers

    assert_equal 2, printers.count
    assert_equal "deadbeef1", printers[0].name
    assert_equal "deadbeef2", printers[1].name
  end

  def test_find_by_name_finds_the_printer
    stub_printer(name: "deadbeef1")
    stub_printer(name: "deadbeef2")

    refute_nil Ultimaker::Discovery.find_by_name("deadbeef1")
  end

  def test_find_by_name_bang_raises
    stub_printer(name: "deadbeef1")
    stub_printer(name: "deadbeef2")

    assert_raises Ultimaker::PrinterNotFoundError do
      Ultimaker::Discovery.find_by_name!("myultimaker")
    end
  end

  def test_connect
  end

  def test_ultimaker_methods
    assert_respond_to Ultimaker, :discover_printers
    assert_respond_to Ultimaker, :find_by_name
    assert_respond_to Ultimaker, :find_by_name!
  end

  private
  def encode_text_record(**attributes)
    DNSSD::TextRecord.new(attributes).encode
  end

  def stub_printer(firmware_version: "3.5.3.20161221", ip: "192.168.0.#{rand(100...255)}", name: "ultimaker3", serial: SecureRandom.hex(6), type: "9511.0")
    hostname = "ultimakersystem-#{serial}"
    fullname = "#{hostname}._ultimaker._tcp.local."
    target = "#{hostname}.local"

    browse_reply = DNSSD::Reply::Browse.new(nil, 2, 0, hostname, "_ultimaker._tcp", "local.")

    text_record_1 = { firmware_version: firmware_version, machine: type, name: name, type: "printer" }
    text_record_2 = text_record_1.merge(hotend_serial_1: "b397cb6681c0", hotend_type_1: "BB 0.4")
    text_record_3 = text_record_2.merge(hotend_serial_0: "28a7d22effaf", hotend_type_0: "AA 0.4")

    resolve_replies = []
    resolve_replies << DNSSD::Reply::Resolve.new(nil, 1, 0, fullname, "moreflags", 80, encode_text_record(text_record_1))
    resolve_replies << DNSSD::Reply::Resolve.new(nil, 1, 0, fullname, "moreflags", 80, encode_text_record(text_record_2))
    resolve_replies << DNSSD::Reply::Resolve.new(nil, 0, 0, fullname, target, 80, encode_text_record(text_record_3))

    getaddrinfo_reply = DNSSD::Reply::AddrInfo.new(nil, 2, 0, hostname, Socket.pack_sockaddr_in(0, ip), 120)

    @browse_replies << browse_reply
    DNSSD::Service.stubs(:resolve).with(browse_reply).returns(stub_service(resolve_replies))
    DNSSD::Service.stubs(:getaddrinfo).with { |t,| t == "moreflags" }.raises("DNSSD::Service.getaddrinfo called from reply with more_coming flag set")
    DNSSD::Service.stubs(:getaddrinfo).with { |t,| t == target }.returns(stub_service([getaddrinfo_reply]))
  end

  def stub_service(replies)
    stub(each: replies, stop: nil)
  end
end
