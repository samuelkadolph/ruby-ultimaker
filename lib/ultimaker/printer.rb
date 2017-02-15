require "ultimaker/printer/print_job"
require "ultimaker/printer/system"

module Ultimaker
  # A generic Ultimaker printer. Contains most of the methods for controlling an Ultimaker printer.
  class Printer
    def led
    end

    def print_job
    end

    # Gets the active print job or raises an error if there is none.
    # @return [PrintJob]
    # @raise [NoActivePrintJobError]
    def print_job!
    end
  end
end
