module TheMask
  class ProxyList
    class Proxy
      attr_accessor :ip, :port, :username, :password

      def initialize(string = '')
        unless string.empty?
          # Proxy string format = ip:port:username:password
          split_str = string.split ":"
          @ip = split_str[0].to_s
          @port = split_str[1].to_i
          @username = split_str[2].to_s unless split_str[2].nil?
          @password = split_str[3].to_s unless split_str[3].nil?
        else
          @ip = nil
          @port = 0
          @username = nil
          @password = nil
        end
      end

    end

    def initialize(arr = [])
      @proxy_list ||= []
      arr.each{ |element| @proxy_list << [TheMask::ProxyList::Proxy.new(element), 0] } unless arr.empty?
    end

    def get_proxy
      @proxy_list = @proxy_list.sort_by(&:last) # Least used proxy
      @proxy_list[0] = [@proxy_list[0][0], @proxy_list[0][1] + 1]
      @proxy_list[0][0]
    end
  end
end