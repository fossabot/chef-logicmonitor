#
# Cookbook Name:: logicmonitor
# Resource:: device
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

require 'json'

provides :logicmonitor_device
resource_name :logicmonitor_device

property :host, String, name_property: true
property :display_name, String
property :description, String
property :link, String
property :disable_alerting, [true, false], default: false
property :host_groups, Array, required: true
property :preferred_collector, Integer, required: true
property :enable_netflow, [true, false], default: false
property :netflow_collector, Integer
property :custom_properties, Array
property :account_name, String, required: true
property :access_id, String, required: true
property :access_key, String, required: true

action :create do
  path = '/device/devices'

  data = {
    'name' => new_resource.host,
    'displayName' => new_resource.display_name || new_resource.host,
    'preferredCollectorId' => new_resource.preferred_collector,
    'hostGroupIds' => new_resource.host_groups.join(',')
  }

  data['description'] = new_resource.description if new_resource.description
  data['link'] = new_resource.link if new_resource.link
  data['disableAlerting'] = new_resource.disable_alerting if new_resource.disable_alerting
  data['customProperties'] = new_resource.custom_properties if new_resource.custom_properties

  if new_resource.enable_netflow
    data['enableNetflow'] = new_resource.enable_netflow
    data['netflowCollectorId'] = new_resource.netflow_collector
  end

  payload = data.to_json

  http_request "logicmonitor-device-#{new_resource.host}" do
    action :post
    url "https://#{new_resource.account_name}.logicmonitor.com/santaba/rest#{path}"
    message payload
    headers ({
      'Authorization' => signature(new_resource.access_id, new_resource.access_key, 'POST', path, payload),
      'Content-Type' => 'application/json'
    })
  end
end

action_class do
  include Logicmonitor::Authorization
end
