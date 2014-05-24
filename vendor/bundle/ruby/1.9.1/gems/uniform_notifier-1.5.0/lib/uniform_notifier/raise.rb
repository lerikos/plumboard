module UniformNotifier
  class Raise < Base
    def self.active?
      @exception_class
    end

    def self.out_of_channel_notify( message )
      return unless self.active?

      raise @exception_class, message
    end

    def self.setup_connection(exception_class)
      @exception_class = exception_class == true ? Exception : exception_class
    end
  end
end
