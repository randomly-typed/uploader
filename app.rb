# frozen_string_literal: true
require 'webrick'
require 'net/http'
require 'json'

require './environment.rb'

def get_authorization_url(client, site, redirect_uri)
  "#{site}/oauth/authorize?client_id=#{client}&redirect_uri=#{redirect_uri}"
end

def get_access_token_url(client, secret, code, site, redirect_uri)
  "#{site}/oauth/access_token?client_id=#{client}&redirect_uri=#{redirect_uri}&client_secret=#{secret}&code=#{code}"
end

def perform_browser_authorization(url)
  code = nil
  server = WEBrick::HTTPServer.new :Port => 8080
  server.mount_proc '/oauth2/callback' do |req, res|
    code = req.query_string.match(/code=(.*)/)[1]
    server.stop
  end

  # The order is weird here. `server.start` is blocking, so the other request needs to be launch first.
  system('firefox', url)
  server.start
  code
end

def get_authorization_token
  request_url = get_authorization_url(
    ENV['client_id'],
    'https://www.mixcloud.com',
    'http://localhost:8080/oauth2/callback'
  )
  code = perform_browser_authorization(request_url)
  access_token_url = get_access_token_url(
    ENV['client_id'],
    ENV['client_secret'],
    code,
    'https://www.mixcloud.com',
    'http://localhost:8080/oauth2/callback'
  )
  puts access_token_url

  JSON.parse(Net::HTTP.get(URI(access_token_url)))['access_token']
end

code = get_authorization_token
puts code
