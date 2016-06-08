require 'socksify'
require 'socksify/http'

module MechanizeSOCKSSupport
  class Mechanize::HTTP::Agent
    public
      def set_socks(addr, port)
        set_http unless @http
        @old_http = @http
        class << @http
          attr_accessor :socks_addr, :socks_port

          def http_class
            Net::HTTP.SOCKSProxy(socks_addr, socks_port)
          end
        end
        @http.socks_addr = addr
        @http.socks_port = port
      end

      def set_proxy addr, port, user = nil, pass = nil
        @http = @old_http unless @old_http.nil?
        super
      end

    private
      def set_http
        @http = Net::HTTP::Persistent.new 'mechanize'
        @http.idle_timeout = 5
        @http.keep_alive   = 300
      end
  end
end