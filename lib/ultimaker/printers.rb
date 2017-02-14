require "ultimaker/printer"

module Ultimaker
  # The Ultimaker 3 printer.
  class Ultimaker3 < Printer
  end

  # The Ultimaker 3 Extended printer.
  class Ultimaker3Extended < Ultimaker3
  end

  TYPES = Hash.new(Printer)
  TYPES["9066"] = Ultimaker3
  TYPES["9511"] = Ultimaker3Extended

  VARIANTS = Hash.new(Printer)
  VARIANTS["Ultimaker 3"] = Ultimaker3
  VARIANTS["Ultimaker 3 Extended"] = Ultimaker3Extended
end
