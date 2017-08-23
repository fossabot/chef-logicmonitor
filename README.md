# logicmonitor

LWRP cookbook for configuring Logicmonitor devices.

## Resources

### logicmonitor_device

Manage a device.

#### Actions:

- `create`: Adds the device

#### Properties:

- `host`: Required - the host name or IP address of the device.
- `display_name`: The display name of the device. Default: `host`
- `description`: The device description.
- `link`: The URL link associated with the device.
- `disable_alerting`: Indicates whether alerting is disabled (`true`) or enabled (`false`) for this device. Default: `false`
- `host_groups`: Required - the Id(s) as string(s) or substring(s) of the groups the device is in as an array.
- `preferred_collector`: Required - the Id as a string or a substring found in the hostname of the preferred collector(s) assigned to monitor the device. If more than one is found, the one with the fewest hosts is used.
- `enable_netflow`: Indicates whether Netflow is enabled (`true`) or disabled (`false`) for the device. Default: `false`
- `netflow_collector`: Required if `enable_netflow` is set - the Id of the netflow collector associated with the device.
- `custom_properties`: Define custom properties for this device. Each property needs to have a name and a value. Example: `[{"name":"snmp.version","value":"v2c"},{"name":"location","value":"Santa Barbara, CA"}]`
- `account_name`: Required - the name of your Logicmonitor account.
- `access_id`: Required - the access_id of your API key.
- `access_key`: Required - the access_key of your API key.

#### Examples:

```ruby
logicmonitor_device '10.36.11.240' do
  host_groups ['2', 'Servers/East']
  preferred_collector '85'
  account_name 'api'
  access_id node['api']['access_id']
  access_key node['api']['access_key']
end
```
