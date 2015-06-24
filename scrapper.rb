require 'rubygems'
require 'mechanize'
require 'digest'
require 'date'

agent = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
}

url = 'https://bikesantiago.bcycle.com/station-locations-new/'
agent.get( url ) { |page|
    # puts page.header
    xpath = '//*[@id="T1E3C9100001_controlContentContainer"]/script'

    jstext = page.parser.xpath(xpath).to_s.strip
    coordinates = []
    status = []
    regex = /var point = new google\.maps\.LatLng\((-\d+\.\d+),\s*(-\d+\.\d+)/

    jstext.scan(regex){ |m|
        hash = Digest::MD5.new.hexdigest( m[0] + m[1] )
        coordinates << {:hash => hash, :lat => m[0].to_f, :lng => m[1].to_f }
    }

    regex = /var icon = \'\/Controls\/StationLocationsMap\/Images\/marker-(outofservice|active)/
    jstext.scan(regex){ |m|
        status << { :status => m[0] }
    }

    tmp = jstext
            .scan(/point, "(.*)"/)
            .to_a
            .collect { |part|
                data = part[0]
                    .gsub(/<[\w='"\s\/]+>/, '|')
                    .gsub(/\|\s+\|/, '|')
                    .gsub(/\|+/, '|')
                    .gsub(/(^\|+|\|$)/, '')
                    .split('|')

                address = data.slice(0..-5).join(', ')

                {
                    :address => address,
                    :bikes_availables => data[-3].to_i,
                    :docks_availables => data[-1].to_i
                }
            }

    puts coordinates.zip(tmp, status).collect { |t| t[0].merge( t[1] ) }.json
}
