# Borderlands

API binding and CLI tool for Akamai content delivery network APIs.

## Installation

    $ gem install borderlands

## Configuration

This tool utilises Akamai's Property Manager API to discover contracts, groups
and properties.  Accordingly, API credentials will be required. These should be
configured in `$HOME/.edgerc` in a section named `default`, as per the below
example. You will need to create Akamai Property Manager API authentication
credentials in Luna.

    [default]
    client_secret = secret_goes_here
    client_token = akab-aoishfiuhwefiuhwefiuhwefihuwef
    max-body = 131072
    access_token = akab-oijqwfiojwegf0hwefoihwefwoo
    host = akab-oihafoihwefoihwefoihwefoihwefoih.luna.akamaiapis.net

## Usage

    $ borderlands help

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fairfaxmedia/borderlands.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

