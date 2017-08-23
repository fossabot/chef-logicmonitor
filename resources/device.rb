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
  lookup = client.get('/device/devices?filter=name:grasp-linadm1')
  if lookup && lookup['data']['total'] > 0
    ::Chef::Log.info("logicmonitor-device-#{new_resource.host} already exists, skipping")
  else
    ::Chef::Log.info("logicmonitor-device-#{new_resource.host} does not exist, creating")
    client.post('/device/devices', properties)
  end
end

action_class do
  def client
    @client ||= Logicmonitor::Client.new(
      new_resource.account_name,
      new_resource.access_id,
      new_resource.access_key
    )
  end

  def properties
    return @properties if @properties

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

    @properties = data
  end
end
