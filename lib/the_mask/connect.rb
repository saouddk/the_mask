module TheMask
  class Connect
    attr_accessor :socket

    def initialize(options = {})
      @socket = TheMask::Socket.new options
    end

    def open_url(url)
      @socket.open_url url
    end
  end
end