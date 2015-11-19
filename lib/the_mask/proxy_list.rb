module TheMask
  class ProxyList
    #TheMask::ProxyList::Proxy class
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
    #ProxyList class
    attr_accessor :proxy_list

    def initialize(arr = [])
      @proxy_list ||= []

      arr.each do |element|
        @proxy_list << [TheMask::ProxyList::Proxy.new(element), 0] unless arr.empty?
      end
    end

    def get_proxy
      if @proxy_list.empty?
        raise "Tried to get_proxy when proxy list is empty. Check that your input proxy list is populated."
      end

      @proxy_list = @proxy_list.sort_by(&:last) # Least used proxy list sort by 2nd element in inner array
      @proxy_list[0] = [@proxy_list[0][0], @proxy_list[0][1] + 1]
      @proxy_list[0][0]
    end

    def remove_proxy!(proxy)
      @proxy_list.delete(proxy)
    end
  end
end