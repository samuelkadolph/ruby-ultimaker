require "ultimaker/connection"
require "ultimaker/printers"
require "ultimaker/version"

# Ultimaker provides code to let you connect to the network enabled Ultimaker printers and consume their API which
# includes (but not limited to): controlling the LEDs, streaming the webcam, sending print jobs.
#
# * Source Code: https://github.com/samuelkadolph/ruby-ultimaker
# * Ultimaker: https://ultimaker.com
# * Ultimaker 3: https://ultimaker.com/en/products/ultimaker-3
# * Ultimaker API: https://ultimaker.com/en/community/23283-inside-the-ultimaker-3-day-2-remote-access-part-1
#
# @author Samuel Kadolph <samuel@kadolph.com
module Ultimaker
  class << self
    # Connects to an Ultimaker printer and returns an instance of the corresponding printer class.
    # @param [String] address The host or IP address to connect to.
    def connect(address)
    end
  end
end
