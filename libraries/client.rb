#
# Cookbook Name:: logicmonitor
# Library:: client
#
# Copyright:: 2017, Granicus
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'base64'
require 'cgi'
require 'date'
require 'json'
require 'net/http'
require 'net/https'
require 'openssl'
require 'uri'

module Logicmonitor
  class Client
    attr_accessor :account, :access_id, :access_key

    def initialize(account, access_id, access_key)
      @account = account
      @access_id = access_id
      @access_key = access_key
      @uri = URI("https://#{account}.logicmonitor.com/santaba/rest")
      @client = Net::HTTP.new(@uri.host, @uri.port)
      @client.use_ssl = true
      @client.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    def get(path)
      request = Net::HTTP::Get.new(URI(File.join(@uri.to_s, path)).request_uri)
      request['Authorization'] = signature('GET', path, '')
      perform(request)
    end

    def post(path, data, method = 'POST')
      request_class = Object.const_get("Net::HTTP::#{method.capitalize}")
      request = request_class.new(URI(File.join(@uri.to_s, path)).request_uri)
      request.body = (data.is_a?(String) ? data : data.to_json)
      request['Authorization'] = signature(method, path, request.body)
      perform(request)
    end

    def put(path, data)
      post(path, data, 'PUT')
    end

    def patch(path, data)
      post(path, data, 'PATCH')
    end

    def perform(request)
      request['Content-Type'] = 'application/json'
      body = nil
      @client.start do |client|
        response = client.request(request)
        body = JSON.parse(response.body) rescue response.body
      end
      body
    end

    def signature(method, path, data)
      self.class.signature(@access_id, @access_key, method, path, data)
    end

    class << self
      def signature(access_id, access_key, method, path, data)
        timestamp = ::DateTime.now.strftime('%Q')
        signature = ::Base64.strict_encode64(
          ::OpenSSL::HMAC.hexdigest(
            ::OpenSSL::Digest.new('sha256'),
            access_key,
            "#{method}#{timestamp}#{data}#{URI(path).path}"
          )
        )
        "LMv1 #{access_id}:#{signature}:#{timestamp}"
      end
    end
  end
end
