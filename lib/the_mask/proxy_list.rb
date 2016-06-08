module TheMask
  class ProxyList
    # TheMask::ProxyList::Proxy class
    class Proxy
      attr_accessor :ip, :port, :username, :password, :type, :socks_version
      HTTP_PROXY = :http
      SOCKS_PROXY = :socks
      SUPPORTED_SOCKS_VERSIONS = ['4', '5']

      def initialize(input_string = '')
        unless input_string.empty?
          # Proxy string format = ip:port:username:password
          split_str = input_string.split(':')
          last_element = split_str[-1].to_s.downcase

          # Check if proxy has SOCKS parameter enabled, by default a proxy will always be a HTTP/s proxy
          if last_element.start_with?(SOCKS_PROXY.to_s)
            @type = SOCKS_PROXY
            socks_version = last_element[-1]
            if SUPPORTED_SOCKS_VERSIONS.include?(socks_version)
              @socks_version = socks_version.to_i
            else
              # Default version is the latest SOCKS, in this case ver. 5s
              @socks_version = SUPPORTED_SOCKS_VERSIONS[-1].to_i
            end
          else
            @type = HTTP_PROXY
          end

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

      def is_SOCKS?
        @type == SOCKS_PROXY
      end

      def is_HTTP?
        @type == HTTP_PROXY
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