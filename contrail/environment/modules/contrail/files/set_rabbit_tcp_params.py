# Copyright (c) 2013 Juniper Networks, Inc. All rights reserved.
#
import commands
import sys


def main(args_str=None):

    if commands.getstatusoutput("grep '^net.ipv4.tcp_keepalive_time' /etc/sysctl.conf")[0] != 0:
        commands.getstatusoutput("echo 'net.ipv4.tcp_keepalive_time = 5' >> /etc/sysctl.conf")
    else:
        commands.getstatusoutput("sed -i 's/net.ipv4.tcp_keepalive_time\s\s*/net.ipv4.tcp_keepalive_time = 5/' /etc/sysctl.conf")
    if commands.getstatusoutput("grep '^net.ipv4.tcp_keepalive_probes' /etc/sysctl.conf")[0] != 0:
        commands.getstatusoutput("echo 'net.ipv4.tcp_keepalive_probes = 5' >> /etc/sysctl.conf")
    else:
        commands.getstatusoutput("sed -i 's/net.ipv4.tcp_keepalive_probes\s\s*/net.ipv4.tcp_keepalive_probes = 5/' /etc/sysctl.conf")
    if commands.getstatusoutput("grep '^net.ipv4.tcp_keepalive_intvl' /etc/sysctl.conf")[0] != 0:
        commands.getstatusoutput("echo 'net.ipv4.tcp_keepalive_intvl = 1' >> /etc/sysctl.conf")
    else:
        commands.getstatusoutput("sed -i 's/net.ipv4.tcp_keepalive_intvl\s\s*/net.ipv4.tcp_keepalive_intvl = 1/' /etc/sysctl.conf")




if __name__ == "__main__":
     main(sys.argv[1:])
