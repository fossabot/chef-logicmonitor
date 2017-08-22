#
# Cookbook Name:: logicmonitor
# Library:: authorization
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
require 'date'
require 'openssl'

module Logicmonitor
  module Authorization
    def signature(access_id, access_key, method, path, data)
      timestamp = ::DateTime.now.strftime('%Q')
      signature = ::Base64.strict_encode64(
        ::OpenSSL::HMAC.hexdigest(
          ::OpenSSL::Digest.new('sha256'),
          access_key,
          "#{method}#{timestamp}#{data}#{path}"
        )
      )
      "LMv1 #{access_id}:#{signature}:#{timestamp}"
    end
  end
end
