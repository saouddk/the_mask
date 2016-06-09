require_relative 'mechanize_socks_support'

module TheMask
  include MechanizeSOCKSSupport

  class Socket
    DEFAULT_OPEN_TIMEOUT = 3 # seconds
    DEFAULT_READ_TIMEOUT = 3 # seconds
    GENERAL_TIMEOUT = 5 # seconds
    MAXIMUM_TRIES = 3
    MINIMUM_PAGE_LENGTH = 100 # bytes
    FORCE_READ = false
    RESET_USER_AGENT = true
    MIN_PROXY_RESPONSE_TIME = nil # seconds, default: nil = do not remove proxies
    SOCKS_INCREASE_TIMEOUTS = 0.5 # increase timeout duration by specified magnitude if proxy used for retrieval is SOCKS4/5

    def initialize(options = {})
      @proxies = nil
      @socks_increase_timeouts = options[:socks_increase_timeouts] || SOCKS_INCREASE_TIMEOUTS
      @timeout = options[:timeout] || GENERAL_TIMEOUT
      @max_tries = options[:max_tries] || MAXIMUM_TRIES
      @force = options[:force] || FORCE_READ
      @min_page_length = options[:min_page_length] || MINIMUM_PAGE_LENGTH
      @reset_user_agent = options[:reset_ua] || RESET_USER_AGENT
      @min_proxy_response_time = options[:min_proxy_response_time] || MIN_PROXY_RESPONSE_TIME

      @agent = Mechanize.new
      @agent.history.max_size = 0

      @open_timeout = options[:open_timeout] || DEFAULT_OPEN_TIMEOUT
      @read_timeout = options[:read_timeout] || DEFAULT_READ_TIMEOUT

      if options[:proxies]
        @proxies = TheMask::ProxyList.new(options[:proxies])
      else
        @proxies = TheMask::ProxyList.new([options[:proxy]])
      end

      @agent.user_agent = TheMask.get_random_user_agent_str unless @reset_user_agent
    end

    def open_url(url)
      read_proc = Proc.new do
        proxy = nil # Selected proxy
        tries = 0 # Total URL retrieval tries
        page_data = nil # Retrieved page html data
        timeout_adjustments = nil # Adjustments to timeouts based on proxy type

        # Variables for timing the GET request
        end_time = nil
        start_time = nil

        begin
          tries += 1

          if !@force && tries > @max_tries
            raise "TheMask: maximum tries reached for URL = #{url} after #{tries} tries. Check the availability of the host or your proxy settings."
          end

          @agent.user_agent = TheMask.get_random_user_agent_str if @reset_user_agent

          begin
            unless @proxies.nil?
              begin
                proxy = @proxies.get_proxy

                if proxy.is_SOCKS?
                  @agent.agent.set_socks proxy.ip, proxy.port
                  timeout_adjustments = calculate_timeouts @socks_increase_timeouts
                elsif proxy.is_HTTP?
                  if proxy.username && proxy.password
                    @agent.set_proxy proxy.ip, proxy.port, proxy.username, proxy.password
                  else
                    @agent.set_proxy proxy.ip, proxy.port
                  end
                  timeout_adjustments = calculate_timeouts
                else
                  raise "TheMask: unknown proxy type '#{proxy.type}'."
                end
              end
            end
          rescue Timeout::ExitException => e
            # Exception timeout from mechanize
            @proxies.remove_proxy!(proxy)
            retry
          end
          @agent.open_timeout = timeout_adjustments[:open_timeout]
          @agent.read_timeout = timeout_adjustments[:read_timeout]
          Timeout::timeout(timeout_adjustments[:timeout]) do
            start_time = Time.now
            page_data = @agent.get url
            end_time = Time.now
          end

        rescue Errno::ETIMEDOUT => e
          retry
        rescue Net::HTTP::Persistent::Error => e
          retry
        rescue Timeout::Error => e
          retry
        rescue SOCKSError => e
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

        unless @min_proxy_response_time.nil? || start_time.nil? || end_time.nil?
          # Remove proxy from list if response time is longer than the minimum response time provided in options
          response_time = end_time - start_time
          @proxies.remove_proxy!(proxy) if response_time > @min_proxy_response_time
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

    private
      def calculate_timeouts(increase_magnitude = 0)
        {
            timeout: (@timeout + (@timeout * increase_magnitude)),
            open_timeout: (@open_timeout + (@open_timeout * increase_magnitude)),
            read_timeout: (@read_timeout + (@read_timeout * increase_magnitude))
        }
      end
  end
end