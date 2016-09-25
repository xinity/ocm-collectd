Hostname "{{ .Env "COLLECTD_HOST" }}"

FQDNLookup false
Interval {{ .Env "COLLECTD_INTERVAL" }}
Timeout 2
ReadThreads 5

LoadPlugin write_graphite
<Plugin "write_graphite">
    <Carbon>
        Host "{{ .Env "GRAPHITE_HOST" }}"
        Port "{{ .Env "GRAPHITE_PORT" }}"
        Protocol "tcp"
        Prefix "{{ .Env "GRAPHITE_PREFIX" }}"
        StoreRates true
        EscapeCharacter "."
        AlwaysAppendDS false
        SeparateInstances true
    </Carbon>
</Plugin>


#LoadPlugin apache
LoadPlugin conntrack
LoadPlugin contextswitch
LoadPlugin cpu
#LoadPlugin curl
#LoadPlugin curl_json
#LoadPlugin curl_xml
LoadPlugin df
LoadPlugin disk
LoadPlugin interface
LoadPlugin irq
LoadPlugin load
LoadPlugin memory
LoadPlugin mysql
#LoadPlugin postgresql
LoadPlugin processes
#LoadPlugin protocols
#<LoadPlugin python>
#  Globals true
#</LoadPlugin>
#LoadPlugin redis
LoadPlugin swap
LoadPlugin tcpconns
#LoadPlugin unixsock
LoadPlugin uptime
LoadPlugin users
LoadPlugin uuid
LoadPlugin vmem
#LoadPlugin Varnish

#<Plugin mysql>
#	<Database db_name>
#		Host "database.serv.er"
#		User "root"
#		Password "password"
#		MasterStats true
#		ConnectTimeout 10
#		InnodbStats true
#	</Database>
#</Plugin>

LoadPlugin exec
<Plugin exec>
  Exec "collectd-docker-collector" "/usr/bin/collectd-docker-collector" "-endpoint" "unix:///var/run/docker.sock" "-host" "{{ .Env "COLLECTD_HOST" }}" "-interval" "{{ .Env "COLLECTD_INTERVAL" }}"
</Plugin>
