module TheMask

  def self.get_data_from_url(url, options = {})
    socket = TheMask::Socket.new options
    socket.open_url url
  end

end