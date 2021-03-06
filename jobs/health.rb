#!/usr/bin/env ruby
require 'net/http'
require 'uri'
require 'httparty'
require 'json'

#
### Global Config
#
# httptimeout => Number in seconds for HTTP Timeout. Set to ruby default of 60 seconds.
# ping_count => Number of pings to perform for the ping method
#
httptimeout = 60
ping_count = 10

#
# Check whether a server is Responding you can set a server to
# check via http request or ping
#
# Server Options
#   name
#       => The name of the Server Status Tile to Update
#   url
#       => Either a website url or an IP address. Do not include https:// when using ping method.
#   method
#       => http
#       => ping
#
# Notes:
#   => If the server you're checking redirects (from http to https for example)
#      the check will return false
#
servers = [
    {name: 'licences stage', url: 'https://licences-stage.hmpps.dsd.io/health', method: 'http'},
    {name: 'licences preprod', url: 'http://health-kick.hmpps.dsd.io/https/licences-preprod.service.hmpps.dsd.io', method: 'http'},
    {name: 'licences prod', url: 'http://health-kick.hmpps.dsd.io/https/licences.service.hmpps.dsd.io', method: 'http'},

    {name: 'batchload stage', url: 'https://nomis-batchload-stage.hmpps.dsd.io/health', method: 'http'},
    {name: 'batchload preprod', url: 'http://health-kick.hmpps.dsd.io/https/nomis-batchload-preprod.service.hmpps.dsd.io', method: 'http'},
    {name: 'batchload prod', url: 'http://health-kick.hmpps.dsd.io/https/nomis-batchload.service.hmpps.dsd.io', method: 'http'},
]
def gather_health_data(server)
    puts "requesting #{server[:url]}..."

    server_response = HTTParty.get(server[:url], headers: { 'Accept' => 'application/json' }, format: 'json').body

    puts "Result from #{server[:url]} is #{server_response}"

    begin
      JSON.parse(server_response)
    rescue
      puts "Invalid response"
      {"healthy"=>false}
    end
end

SCHEDULER.every '60s', first_in: 0 do |_job|
    servers.each do |server|
        result = gather_health_data(server)
        send_event(server[:name], result: result)
    end
end