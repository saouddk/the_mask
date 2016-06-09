require 'socksify'
require 'socksify/http'

module MechanizeSOCKSSupport
  def set_proxy addr, port, user = nil, pass = nil
    @socks = false
    super
  end

  def fetch(uri, method = :get, headers = {}, params = [], referer = current_page, redirects = 0)
    if @socks && !@socks_http.nil?
      html = @socks_http.get URI(uri)
      page = Struct.new(:uri, :body)
      page.new(uri, html)
    else
      super
    end
  end

  class Mechanize::HTTP::Agent
    prepend MechanizeSOCKSSupport
    attr_accessor :http, :old_http, :socks

    public
      def set_socks(addr, port)
        set_http unless @http
        @socks_http = Net::HTTP::SOCKSProxy(addr, port)
        @socks = true
      end

    private
      def set_http
        @http = Net::HTTP::Persistent.new 'mechanize'
        @http.idle_timeout = 5
        @http.keep_alive   = 300
      end
  end
end