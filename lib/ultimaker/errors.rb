module Ultimaker
  # Base error class for all Ultimaker errors.
  class Error < ::StandardError
    # def initialize
  end

  # Raised when there is no active job and you call {Printer.print_job!}.
  class NoActivePrintJobError < Error
  end

  # Raised when no printer is found and you call {Discovery.find_by_name!}.
  class PrinterNotFoundError < Error
  end
end
