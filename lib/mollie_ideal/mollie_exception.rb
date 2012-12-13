module MollieIdeal
  class MollieException < Exception
    attr_accessor :errorcode
    attr_accessor :message
    attr_accessor :type

    def initialize(errorcode, message, type)
      self.errorcode = errorcode
      self.message   = message
      self.type      = type
    end
  end
end