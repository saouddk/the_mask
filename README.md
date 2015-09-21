# TheMask

![alt tag](http://i.imgur.com/gecDZon.jpg)

Tired of issues involved with data mining? Put on The Mask and try data mining designed for the next generation.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'the_mask'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install the_mask

## Usage

`mask_connect = TheMask::Connect.new(read_timeout: 4, open_timeout: 4, max_tries: 4)
 mask_connect.open_url 'http://www.abcdefg.com'
`
  
This will return the body data from the supplied URL.  
  
Available options:  
`read_timeout = Read timeout in seconds (default: 3)`  
`open_timeout = Open timeout in seconds (default: 3)`  
`timeout = Timeout for whole procedure in seconds (default: 5)`  
`max_tries = Maximum attempts in reading the page (default: 3)`  
`min_page_length = Minimum page length in bytes, if not satisfied, reattempt retrieval (default: 100 bytes)`   
`reset_ua = Reset user agent on every request. (default: true)`  
`force = Force continuous opening of page until data is retrieved (default: false)`  

Proxy options example:  
`mask_connect = TheMask::Connect.new(proxy: { ip: '127.0.0.1', port: 8080, username: 'asd333', password: 'asd333' })`  
  
Or supply multiple proxies with an array:  
`mask_connect = TheMask::Connect.new(proxies: ['111.11.1.1:80', '10.10.101.10:800', '192.10.10.1:80:sdad:asdasd'])`  


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/saouddk/the_mask. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

