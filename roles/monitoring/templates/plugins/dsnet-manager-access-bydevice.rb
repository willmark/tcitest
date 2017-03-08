#!/usr/bin/env /opt/sensu/embedded/bin/ruby

require 'sensu-plugin/check/cli'
require 'net/http'
require 'openssl'
require 'socket'
require 'json'

class DsnetManagerAccess < Sensu::Plugin::Check::CLI

  option :ip,
         :description => "Address of dsNet Manager",
         :short => "-i IP_ADDRESS",
         :required => true

  option :user,
         :description => "Username for dsNet Manager",
         :short => "-u USERNAME",
         :required => true

  option :pass,
         :description => "Password for dsNet Manager",
         :short => "-p PASSWORD",
         :required => true

  option :no_ssl,
         :description => "Disable ssl verification",
         :short => "-n",
         :boolean => true,
         :default => false

  option :cert_path,
         :description => "Path to ssl cert",
         :short => "-c PATH"

  option :service_owner,
         :description => "Service owner for child checks",
         :short => "-s OWNER",
         :default => "cleversafe"

  option :tags,
         :description => "Tags for child checks",
         :short => "-t TAG1,TAG2,...",
         :default => nil

  option :dependencies,
         :description => "Dependencies for child checks",
         :short => "-d DEP1,DEP2,...",
         :default => nil

  option :handle,
         :description => "Should the child checks be handled",
         :short => "-b",
         :boolean => true,
         :default => false

  option :handlers,
         :description => "Handlers for the child checks",
         :short => "-l HANDL1,HANDL2,...",
         :default => "default"

  def run
    devices = build_device_list
    storage_pools = build_storage_pool_list

    uri = URI("https://#{config[:ip]}/manager/api/json/1.0/eventConsole.adm?streamTypes=openIncidentStates&eventLevels=warning&eventLevels=error&eventLevels=critical")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.ca_file = config[:cert_path]
    http.verify_mode = config[:no_ssl] ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(config[:user], config[:pass])

    begin
      res = http.request(request)
    rescue Exception => e
      message "Could not reach dsNet Manager - #{e}"
      critical
    end

    if res.is_a? Net::HTTPSuccess
      response = res.body
    else
      message "Could not read from dsNet Manager - #{res.message}"
      critical
    end

    input = JSON.parse(response)["responseData"]["streamElements"]
    for device in devices
      errors = ""
      warnings = ""
      level = 0
      for problem in input
        if problem["eventSource"]["id"] == device["id"] or
            (not problem["eventSource"]["type"].eql? "device" and device["deviceType"].eql? "manager")
          error_source = ""
          if problem["eventSource"]["type"].eql? "storagePoolGroup"
            error_source = storage_pools.find { |x| x["id"] == problem["eventSource"]["id"] }["name"] + ": "
          elsif not problem["eventSource"]["type"].eql? "device"
            error_source = "#{problem["eventSource"]["type"]} #{problem["eventSource"]["id"]}: "
          end
          if problem["eventLevel"].eql? "critical"
            errors += " #{error_source}CRITICAL: #{problem["message"]}"
            level = 2
          elsif problem["eventLevel"].eql? "error"
            errors += " #{error_source}#{problem["message"]}"
            level = 2
          elsif problem["eventLevel"].eql? "warning"
            warnings += " #{error_source}#{problem["message"]}"
            if level < 1
              level = 1
            end
          end
        end
      end
      out_message = ""
      if errors.eql? ""
        if warnings.eql? ""
          out_message = "System OK."
        else
          out_message = warnings
        end
      else
        if warnings.eql? ""
          out_message = errors
        else
          out_message = "--Errors:#{errors} --Warnings:#{warnings}"
        end
      end
      out = { :source => device["hostname"],
              :name => "cleversafe-status",
              :output => out_message,
              :status => level,
              :service_owner => config[:service_owner],
              :dependencies => config[:dependencies].nil? ? nil : config[:dependencies].split(','),
              :tags => config[:tags].nil? ? nil : config[:tags].split(','),
              :handle => config[:handle],
              :handlers => config[:handlers].split(',')}

      sock = TCPSocket.open("localhost", 3030)
      sock.print(JSON.generate(out))
      sock.close
    end

    message "dsNet Manager reachable"
    ok
  end

  def build_device_list
    uri = URI("https://#{config[:ip]}/manager/api/json/1.0/listDevices.adm")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.ca_file = config[:cert_path]
    http.verify_mode = config[:no_ssl] ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(config[:user], config[:pass])

    begin
      res = http.request(request)
    rescue Exception => e
      message "Could not reach dsNet Manager - #{e}"
      critical
    end

    if res.is_a? Net::HTTPSuccess
      response = res.body
    else
      message "Could not read from dsNet Manager - #{res.message}"
      critical
    end

    input = JSON.parse(response)["responseData"]["devices"]

    input
  end

  def build_storage_pool_list
    uri = URI("https://#{config[:ip]}/manager/api/json/1.0/listStoragePools.adm")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.ca_file = config[:cert_path]
    http.verify_mode = config[:no_ssl] ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(config[:user], config[:pass])

    begin
      res = http.request(request)
    rescue Exception => e
      message "Could not reach dsNet Manager - #{e}"
      critical
    end

    if res.is_a? Net::HTTPSuccess
      response = res.body
    else
      message "Could not read from dsNet Manager - #{res.message}"
      critical
    end

    input = JSON.parse(response)["responseData"]["storagePools"]

    input
  end

end
