import commands
import sys


def main(args_str=None):
    openstack_ip_list_str = sys.argv[1]
    os_ip_list = openstack_ip_list_str.split(",")
    number_openstack_nodes = len(os_ip_list)

    status,output = commands.getstatusoutput("cat /etc/contrail/mysql.token")
    mysql_token = output
    status,output = commands.getstatusoutput('mysql -uroot -p%s -e "show status like \'wsrep_local_state_comment\'"' %  mysql_token )
    print "wsrep_local_state_comment: %s" % output
    if output.find("Synced") == -1:
        sys.exit(1)
    status,output = commands.getstatusoutput('mysql -uroot -p%s -e "show status like \'wsrep_local_state\'"' %  mysql_token)
    print "wsrep_local_state: %s" % output
    if output.find("4") == -1:
    #if output.find(str(number_openstack_nodes)) == -1:
        sys.exit(1)
    status,output = commands.getstatusoutput('mysql -uroot -p%s -e "show status like \'wsrep_cluster_size\'"' %  mysql_token )
    print "wsrep_cluster_size: %s" % output
    #if output.find("4") == -1:
    if output.find(str(number_openstack_nodes)) == -1:
        sys.exit(1)
if __name__ == "__main__":
         main(sys.argv[1:])

