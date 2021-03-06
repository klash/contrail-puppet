# == Class: contrail::keeplived
#
# This class is used to configure software and services required
# to run keepalived services used by contrail software suit.
#
# === Parameters:
#
# [*vip*]
#     Virtual IP address used by the keepalived service.
#     optional - Defaults to "", in which case this class does not do anything!
#
# [*state*]
#     State of VRRP instance (MASTER or SLAVE).
#     (Optional) - Defaults to "MASTER"
#
# [*priority*]
#     Priority used for VRRP.
#     (optional) - Defaults to "101".
#
# [*virtual_router_id*]
#     Virtual router id value.
#     (Optional) - Defaults to "50".
#
# The puppet module to set up keepalived for contrail
class contrail::keepalived(
    $host_control_ip = $::contrail::params::host_ip,
    $config_ip_list = $::contrail::params::config_ip_list, 
    $internal_vip = $::contrail::params::internal_vip,
    $contrail_internal_vip = $::contrail::params::contrail_internal_vip,
    $keepalived_vrid = $::contrail::params::keepalived_vrid,
    $openstack_ip_list = $::contrail::params::openstack_ip_list 
) inherits ::contrail::params {
    #$vip = undef
    #$ip_list = undef

    notify { "Keepalived - host_control_ip = $host_control_ip":; }
    notify { "Keepalived - config_ip_list = $config_ip_list":; }
    notify { "Keepalived - internal_vip = $internal_vip":; }
    notify { "Keepalived - contrail_internal_vip = $contrail_internal_vip":; }
    notify { "Keepalived - keepalived_vrid = $keepalived_vrid":; }
    notify { "Keepalived - openstack_ip_list = $openstack_ip_list":; }

    $control_data_intf = get_device_name("$host_control_ip")
    if ($host_control_ip in $openstack_ip_list and $internal_vip != "") {
        $vip = $internal_vip
        $ip_list = $openstack_ip_list
        notify { "Keepalived - Setting up internal_vip ":; }

    } elsif ($host_control_ip in $config_ip_list and $contrail_internal_vip != "" ) {
        $vip = $contrail_internal_vip
        $ip_list = $config_ip_list
        notify { "Keepalived - Setting up contrail_internal_vip ":; }

    } else {
        $vip = ""
    }

    if ($vip != "") {
        $tmp_index = inline_template('<%= @ip_list.index(@host_control_ip) %>')
        if ($tmp_index == nil) {
            fail("Host $host_control_ip not found in servers of config roles")
        }
        $config_index = $tmp_index + 1
        $keepalived_priority = $keepalived_vrid + $config_index - 1
        if ($config_index == 1) {
            $keepalived_state = "MASTER"
        }
        else {
            $keepalived_state = "BACKUP"
        }

	include ::keepalived
        $interface = find_matching_interface($vip)

	keepalived::vrrp::script { 'check_haproxy':
	  script => '/usr/bin/killall -0 haproxy',
	}

	keepalived::vrrp::script { 'check_peers':
	  script => '/opt/contrail/bin/chk_ctrldata.sh',
	}
	keepalived::vrrp::instance { "VI_$keepalived_vrid":
	  interface         => $interface,
	  state             => $keepalived_state,
	  virtual_router_id => "$keepalived_vrid",
	  priority          => "$keepalived_priority",
	  auth_type         => 'PASS',
	  auth_pass         => 'secret',
	  virtual_ipaddress => $vip,
          garp_master_refresh => 1,
          garp_master_repeat => 3,
          vmac_xmit_base => true,
          track_interface => $control_data_intf,
	  track_script      => ['check_proxy','check_peers'],
	}
    }
}
