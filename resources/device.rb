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

property :host, String, name_property: true, identity: true
property :display_name, String
property :description, String
property :link, String
property :disable_alerting, [true, false], default: false
property :host_groups, Array, required: true, desired_state: false
property :preferred_collector, String, required: true, desired_state: false
property :enable_netflow, [true, false], default: false
property :netflow_collector, Integer
property :custom_properties, Array
property :account_name, String, required: true, desired_state: false
property :access_id, String, required: true, desired_state: false
property :access_key, String, required: true, desired_state: false

action :create do
  lookup = client.get("/device/devices?filter=name:#{CGI.escape(new_resource.host)}")
  if lookup && lookup['data'] && lookup['data']['total'] > 0
    ::Chef::Log.info("logicmonitor: device for #{new_resource.host} already exists, skipping")
  else
    response = client.post('/device/devices', properties)
    if response['errmsg'] == 'OK'
      ::Chef::Log.info("logicmonitor: created device for #{new_resource.host}")
    else
      raise "logicmonitor: failed to create device for #{new_resource.host} (#{response['errmsg']})"
    end
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

  def host_groups
    return @host_groups if @host_groups
    ids = []
    new_resource.host_groups.each do |host_group|
      if host_group == '0' || host_group.to_i != 0
        ids << host_group
      else
        begin
          lookup = client.get("/device/groups?filter=fullPath~#{CGI.escape(host_group)}&fields=id")
          ids.concat(lookup['data']['items'].map { |i| i['id'] })
        rescue StandardError => e
          ::Chef::Log.error("logicmonitor: could not find ID for host_group: #{host_group}")
          raise e
        end
      end
    end
    @host_groups = ids
  end

  def preferred_collector
    return @preferred_collector if @preferred_collector
    id = new_resource.preferred_collector
    if id == '0' || id.to_i != 0
      id = id.to_i
    else
      begin
        lookup = client.get("/setting/collectors?filter=hostname~#{CGI.escape(id)}&sort=+numberOfHosts&fields=id,numberOfHosts")
        id = lookup['data']['items'][0]['id']
      rescue StandardError => e
        ::Chef::Log.error("logicmonitor: could not find ID for preferred_collector: #{id}")
        raise e
      end
    end
    @preferred_collector = id
  end

  def properties
    return @properties if @properties

    data = {
      'name' => new_resource.host,
      'displayName' => new_resource.display_name || new_resource.host,
      'preferredCollectorId' => preferred_collector,
      'hostGroupIds' => host_groups.join(',')
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
