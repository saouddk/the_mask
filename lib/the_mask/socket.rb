module TheMask
  class Socket
    #TODO: Move from Mechanize to native Sockets ;)
    DEFAULT_OPEN_TIMEOUT = 3 #seconds
    DEFAULT_READ_TIMEOUT = 3 #seconds
    GENERAL_TIMEOUT = 5 #seconds
    MAXIMUM_TRIES = 3
    MINIMUM_PAGE_LENGTH = 100 #bytes
    FORCE_READ = false
    RESET_USER_AGENT = true

    def initialize(options = {})
      @proxies = nil
      @timeout = options[:timeout] || GENERAL_TIMEOUT
      @max_tries = options[:max_tries] || MAXIMUM_TRIES
      @force = options[:force] || FORCE_READ
      @min_page_length = options[:min_page_length] || MINIMUM_PAGE_LENGTH
      @reset_user_agent = options[:reset_ua] || RESET_USER_AGENT

      @agent = Mechanize.new

      @agent.open_timeout = options[:open_timeout] || DEFAULT_OPEN_TIMEOUT
      @agent.read_timeout = options[:read_timeout] || DEFAULT_READ_TIMEOUT

      unless options[:proxies]
        if options[:proxy]
          if options[:proxy][:username] &&  options[:proxy][:password]
            @agent.set_proxy options[:proxy][:ip], options[:proxy][:port], options[:proxy][:username], options[:proxy][:password]
          else
            @agent.set_proxy options[:proxy][:ip], options[:proxy][:port]
          end
        end
      else
        @proxies = TheMask::ProxyList.new(options[:proxies])
      end

      @agent.user_agent = TheMask.get_random_user_agent_str unless @reset_user_agent
    end

    def open_url(url)
      read_proc = Proc.new do
        tries = 0 #Total URL retrieval tries
        page_data = nil #Retrieved page html data

        begin
          tries += 1

          if !@force && tries > @max_tries
            raise "TheMask: maximum tries reached for URL = #{url} after #{tries} tries. Check the availability of the host or your proxy settings."
          end

          @agent.user_agent = TheMask.get_random_user_agent_str if @reset_user_agent

          proxy = nil

          begin
            unless @proxies.nil?
              begin
                proxy = @proxies.get_proxy

                if proxy.username && proxy.password
                  @agent.set_proxy proxy.ip, proxy.port, proxy.username, proxy.password
                else
                  @agent.set_proxy proxy.ip, proxy.port
                end
              end
            end
          rescue Timeout::ExitException => e
            #Exception timeout from mechanize
            @proxies.remove_proxy!(proxy)
            retry
          end

          Timeout::timeout(@timeout) do
            page_data = @agent.get url
          end
        rescue Errno::ETIMEDOUT => e
          retry
        rescue Net::HTTP::Persistent::Error => e
          retry
        rescue Timeout::Error => e
          retry
        rescue SignalException => e
          retry
        rescue Net::HTTPNotFound => e
          retry
        rescue URI::InvalidURIError => e
          retry
        rescue Mechanize::ResponseCodeError => e
          retry
        rescue Net::OpenTimeout => e
          retry
        rescue Net::HTTPInternalServerError => e
          retry
        rescue
          retry
        end
        page_data
      end

      if @force
        while true
          data = read_proc.call

          unless data.nil? || data.body.to_s.empty? || data.body.to_s.length < @min_page_length
            return data.body
          end
        end
      end

      read_proc.call.body
    end
  end
end