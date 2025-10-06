#!/bin/bash
#--------------------------------------------------------------------------------
#                        Zabbix-Proxy CentOS HIT v2.1
#--------------------------------------------------------------------------------

# Recebe parâmetros da linha de execução
nomeItop="$1"
ipProxy="$2"
chaveProxy="$3"

# Se algum parâmetro não for passado, solicita interativamente
if [ -z "$nomeItop" ]; then
    read -p "Digite o código da organização: " nomeItop
fi

if [ -z "$ipProxy" ]; then
    read -p "Digite o IP do Proxy: " ipProxy
fi

if [ -z "$chaveProxy" ]; then
    read -sp "Digite a chave do Proxy: " chaveProxy
    echo
fi

hostname="$(hostname)"

distro="$(cat /etc/*-release | grep CentOS)"
distro_oracle="$(cat /etc/*-release | grep Oracle)"
distro_rocky="$(cat /etc/*-release | grep Rocky)"

if ([[ $distro_oracle == *"Oracle"* ]] && [[ $distro_oracle == *"8"* ]]) || ([[ $distro_rocky == *"Rocky"* ]] && [[ $distro_rocky == *"8"* ]]);
then
		rpm -ivh https://repo.zabbix.com/zabbix/4.4/rhel/8/x86_64/zabbix-release-4.4-1.el8.noarch.rpm
        yum install zabbix-proxy-sqlite3-4.4.7 zabbix-get-4.4.7 zabbix-sender-4.4.7 zabbix-agent-4.4.7 net-snmp-utils nmap ntsysv wget curl vim telnet psmisc -y

echo "
# This is a configuration file for Zabbix proxy daemon
# To get more information about Zabbix, visit http://www.zabbix.com

############ GENERAL PARAMETERS #################

### Option: ProxyMode
#	Proxy operating mode.
#	0 - proxy in the active mode
#	1 - proxy in the passive mode
#
# Mandatory: no
# Default:
# ProxyMode=0

### Option: Server
#	IP address (or hostname) of Zabbix server.
#	Active proxy will get configuration data from the server.
#	For a proxy in the passive mode this parameter will be ignored.
#
# Mandatory: yes (if ProxyMode is set to 0)
# Default:
# Server=

Server=hproxy.hit.com.vc

### Option: ServerPort
#	Port of Zabbix trapper on Zabbix server.
#	For a proxy in the passive mode this parameter will be ignored.
#
# Mandatory: no
# Range: 1024-32767
# Default:
# ServerPort=10051

### Option: Hostname
#	Unique, case sensitive Proxy name. Make sure the Proxy name is known to the server!
#	Value is acquired from HostnameItem if undefined.
#
# Mandatory: no
# Default:
# Hostname=

Hostname=$nomeItop

### Option: HostnameItem
#	Item used for generating Hostname if it is undefined.
#	Ignored if Hostname is defined.
#
# Mandatory: no
# Default:
# HostnameItem=system.hostname

### Option: ListenPort
#	Listen port for trapper.
#
# Mandatory: no
# Range: 1024-32767
# Default:
# ListenPort=10051

### Option: SourceIP
#	Source IP address for outgoing connections.
#
# Mandatory: no
# Default:
# SourceIP=

### Option: LogType
#	Specifies where log messages are written to:
#		system  - syslog
#		file    - file specified with LogFile parameter
#		console - standard output
#
# Mandatory: no
# Default:
# LogType=file

### Option: LogFile
#	Log file name for LogType 'file' parameter.
#
# Mandatory: no
# Default:
# LogFile=

LogFile=/var/log/zabbix/zabbix_proxy.log

### Option: LogFileSize
#	Maximum size of log file in MB.
#	0 - disable automatic log rotation.
#
# Mandatory: no
# Range: 0-1024
# Default:
# LogFileSize=1

LogFileSize=10

### Option: DebugLevel
#	Specifies debug level:
#	0 - basic information about starting and stopping of Zabbix processes
#	1 - critical information
#	2 - error information
#	3 - warnings
#	4 - for debugging (produces lots of information)
#	5 - extended debugging (produces even more information)
#
# Mandatory: no
# Range: 0-5
# Default:
# DebugLevel=3

### Option: EnableRemoteCommands
#       Whether remote commands from Zabbix server are allowed.
#       0 - not allowed
#       1 - allowed
#
# Mandatory: no
# Default:
EnableRemoteCommands=1

### Option: LogRemoteCommands
#       Enable logging of executed shell commands as warnings.
#       0 - disabled
#       1 - enabled
#
# Mandatory: no
# Default:
# LogRemoteCommands=0

### Option: PidFile
#	Name of PID file.
#
# Mandatory: no
# Default:
# PidFile=/tmp/zabbix_proxy.pid

PidFile=/var/run/zabbix/zabbix_proxy.pid

### Option: SocketDir
#	IPC socket directory.
#       Directory to store IPC sockets used by internal Zabbix services.
#
# Mandatory: no
# Default:
# SocketDir=/tmp

SocketDir=/var/run/zabbix

### Option: DBHost
#	Database host name.
#	If set to localhost, socket is used for MySQL.
#	If set to empty string, socket is used for PostgreSQL.
#
# Mandatory: no
# Default:
# DBHost=localhost

### Option: DBName
#	Database name.
#	For SQLite3 path to database file must be provided. DBUser and DBPassword are ignored.
#	Warning: do not attempt to use the same database Zabbix server is using.
#
# Mandatory: yes
# Default:
# DBName=

DBName=/tmp/zabbix_proxy.db

### Option: DBSchema
#	Schema name. Used for IBM DB2 and PostgreSQL.
#
# Mandatory: no
# Default:
# DBSchema=

### Option: DBUser
#	Database user. Ignored for SQLite.
#
# Default:
# DBUser=

DBUser=zabbix

### Option: DBPassword
#	Database password. Ignored for SQLite.
#	Comment this line if no password is used.
#
# Mandatory: no
# Default:
# DBPassword=

### Option: DBSocket
#	Path to MySQL socket.
#
# Mandatory: no
# Default:
# DBSocket=/tmp/mysql.sock

# Option: DBPort
#	Database port when not using local socket. Ignored for SQLite.
#
# Mandatory: no
# Default (for MySQL):
# DBPort=3306

######### PROXY SPECIFIC PARAMETERS #############

### Option: ProxyLocalBuffer
#	Proxy will keep data locally for N hours, even if the data have already been synced with the server.
#	This parameter may be used if local data will be used by third party applications.
#
# Mandatory: no
# Range: 0-720
# Default:
# ProxyLocalBuffer=0

### Option: ProxyOfflineBuffer
#	Proxy will keep data for N hours in case if no connectivity with Zabbix Server.
#	Older data will be lost.
#
# Mandatory: no
# Range: 1-720
# Default:
# ProxyOfflineBuffer=1

### Option: HeartbeatFrequency
#	Frequency of heartbeat messages in seconds.
#	Used for monitoring availability of Proxy on server side.
#	0 - heartbeat messages disabled.
#	For a proxy in the passive mode this parameter will be ignored.
#
# Mandatory: no
# Range: 0-3600
# Default:
# HeartbeatFrequency=60

### Option: ConfigFrequency
#	How often proxy retrieves configuration data from Zabbix Server in seconds.
#	For a proxy in the passive mode this parameter will be ignored.
#
# Mandatory: no
# Range: 1-3600*24*7
# Default:
# ConfigFrequency=3600

### Option: DataSenderFrequency
#	Proxy will send collected data to the Server every N seconds.
#	For a proxy in the passive mode this parameter will be ignored.
#
# Mandatory: no
# Range: 1-3600
# Default:
# DataSenderFrequency=1

############ ADVANCED PARAMETERS ################

### Option: StartPollers
#	Number of pre-forked instances of pollers.
#
# Mandatory: no
# Range: 0-1000
# Default:
# StartPollers=5

### Option: StartIPMIPollers
#	Number of pre-forked instances of IPMI pollers.
#       The IPMI manager process is automatically started when at least one IPMI poller is started.
#
# Mandatory: no
# Range: 0-1000
# Default:
# StartIPMIPollers=0

### Option: StartPollersUnreachable
#	Number of pre-forked instances of pollers for unreachable hosts (including IPMI and Java).
#	At least one poller for unreachable hosts must be running if regular, IPMI or Java pollers
#	are started.
#
# Mandatory: no
# Range: 0-1000
# Default:
# StartPollersUnreachable=1

### Option: StartTrappers
#	Number of pre-forked instances of trappers.
#	Trappers accept incoming connections from Zabbix sender and active agents.
#
# Mandatory: no
# Range: 0-1000
# Default:
# StartTrappers=5

### Option: StartPingers
#	Number of pre-forked instances of ICMP pingers.
#
# Mandatory: no
# Range: 0-1000
# Default:
# StartPingers=1

### Option: StartDiscoverers
#	Number of pre-forked instances of discoverers.
#
# Mandatory: no
# Range: 0-250
# Default:
# StartDiscoverers=1

### Option: StartHTTPPollers
#	Number of pre-forked instances of HTTP pollers.
#
# Mandatory: no
# Range: 0-1000
# Default:
# StartHTTPPollers=1

### Option: JavaGateway
#	IP address (or hostname) of Zabbix Java gateway.
#	Only required if Java pollers are started.
#
# Mandatory: no
# Default:
JavaGateway=$ipProxy

### Option: JavaGatewayPort
#	Port that Zabbix Java gateway listens on.
#
# Mandatory: no
# Range: 1024-32767
# Default:
JavaGatewayPort=10052

### Option: StartJavaPollers
#	Number of pre-forked instances of Java pollers.
#
# Mandatory: no
# Range: 0-1000
# Default:
StartJavaPollers=5

### Option: StartVMwareCollectors
#	Number of pre-forked vmware collector instances.
#
# Mandatory: no
# Range: 0-250
# Default:
StartVMwareCollectors=6

### Option: VMwareFrequency
#	How often Zabbix will connect to VMware service to obtain a new data.
#
# Mandatory: no
# Range: 10-86400
# Default:
# VMwareFrequency=60

### Option: VMwarePerfFrequency
#	How often Zabbix will connect to VMware service to obtain performance data.
#
# Mandatory: no
# Range: 10-86400
# Default:
# VMwarePerfFrequency=60

### Option: VMwareCacheSize
#	Size of VMware cache, in bytes.
#	Shared memory size for storing VMware data.
#	Only used if VMware collectors are started.
#
# Mandatory: no
# Range: 256K-2G
# Default:
VMwareCacheSize=8M

### Option: VMwareTimeout
#	Specifies how many seconds vmware collector waits for response from VMware service.
#
# Mandatory: no
# Range: 1-300
# Default:
VMwareTimeout=10

### Option: SNMPTrapperFile
#	Temporary file used for passing data from SNMP trap daemon to the proxy.
#	Must be the same as in zabbix_trap_receiver.pl or SNMPTT configuration file.
#
# Mandatory: no
# Default:
# SNMPTrapperFile=/tmp/zabbix_traps.tmp

SNMPTrapperFile=/var/log/snmptrap/snmptrap.log

### Option: StartSNMPTrapper
#	If 1, SNMP trapper process is started.
#
# Mandatory: no
# Range: 0-1
# Default:
# StartSNMPTrapper=0

### Option: ListenIP
#	List of comma delimited IP addresses that the trapper should listen on.
#	Trapper will listen on all network interfaces if this parameter is missing.
#
# Mandatory: no
# Default:
# ListenIP=0.0.0.0

### Option: HousekeepingFrequency
#	How often Zabbix will perform housekeeping procedure (in hours).
#	Housekeeping is removing outdated information from the database.
#	To prevent Housekeeper from being overloaded, no more than 4 times HousekeepingFrequency
#	hours of outdated information are deleted in one housekeeping cycle.
#	To lower load on proxy startup housekeeping is postponed for 30 minutes after proxy start.
#	With HousekeepingFrequency=0 the housekeeper can be only executed using the runtime control option.
#	In this case the period of outdated information deleted in one housekeeping cycle is 4 times the
#	period since the last housekeeping cycle, but not less than 4 hours and not greater than 4 days.
#
# Mandatory: no
# Range: 0-24
# Default:
# HousekeepingFrequency=1

### Option: CacheSize
#	Size of configuration cache, in bytes.
#	Shared memory size, for storing hosts and items data.
#
# Mandatory: no
# Range: 128K-8G
# Default:
# CacheSize=8M

### Option: StartDBSyncers
#	Number of pre-forked instances of DB Syncers.
#
# Mandatory: no
# Range: 1-100
# Default:
# StartDBSyncers=4

### Option: HistoryCacheSize
#	Size of history cache, in bytes.
#	Shared memory size for storing history data.
#
# Mandatory: no
# Range: 128K-2G
# Default:
# HistoryCacheSize=16M

### Option: HistoryIndexCacheSize
#	Size of history index cache, in bytes.
#	Shared memory size for indexing history cache.
#
# Mandatory: no
# Range: 128K-2G
# Default:
# HistoryIndexCacheSize=4M

### Option: Timeout
#	Specifies how long we wait for agent, SNMP device or external check (in seconds).
#
# Mandatory: no
# Range: 1-30
# Default:
# Timeout=3

Timeout=30

### Option: TrapperTimeout
#	Specifies how many seconds trapper may spend processing new data.
#
# Mandatory: no
# Range: 1-300
# Default:
# TrapperTimeout=300

### Option: UnreachablePeriod
#	After how many seconds of unreachability treat a host as unavailable.
#
# Mandatory: no
# Range: 1-3600
# Default:
# UnreachablePeriod=45

### Option: UnavailableDelay
#	How often host is checked for availability during the unavailability period, in seconds.
#
# Mandatory: no
# Range: 1-3600
# Default:
# UnavailableDelay=60

### Option: UnreachableDelay
#	How often host is checked for availability during the unreachability period, in seconds.
#
# Mandatory: no
# Range: 1-3600
# Default:
# UnreachableDelay=15

### Option: ExternalScripts
#	Full path to location of external scripts.
#	Default depends on compilation options.
#
# Mandatory: no
# Default:
# ExternalScripts=${datadir}/zabbix/externalscripts

ExternalScripts=/usr/lib/zabbix/externalscripts

### Option: FpingLocation
#	Location of fping.
#	Make sure that fping binary has root ownership and SUID flag set.
#
# Mandatory: no
# Default:
# FpingLocation=/usr/sbin/fping

### Option: Fping6Location
#	Location of fping6.
#	Make sure that fping6 binary has root ownership and SUID flag set.
#	Make empty if your fping utility is capable to process IPv6 addresses.
#
# Mandatory: no
# Default:
# Fping6Location=/usr/sbin/fping6

### Option: SSHKeyLocation
#	Location of public and private keys for SSH checks and actions.
#
# Mandatory: no
# Default:
# SSHKeyLocation=

### Option: LogSlowQueries
#	How long a database query may take before being logged (in milliseconds).
#	Only works if DebugLevel set to 3 or 4.
#	0 - don't log slow queries.
#
# Mandatory: no
# Range: 1-3600000
# Default:
# LogSlowQueries=0

LogSlowQueries=3000

### Option: TmpDir
#	Temporary directory.
#
# Mandatory: no
# Default:
# TmpDir=/tmp

### Option: AllowRoot
#	Allow the proxy to run as 'root'. If disabled and the proxy is started by 'root', the proxy
#	will try to switch to the user specified by the User configuration option instead.
#	Has no effect if started under a regular user.
#	0 - do not allow
#	1 - allow
#
# Mandatory: no
# Default:
# AllowRoot=0

### Option: User
#	Drop privileges to a specific, existing user on the system.
#	Only has effect if run as 'root' and AllowRoot is disabled.
#
# Mandatory: no
# Default:
# User=zabbix

### Option: Include
#	You may include individual files or all files in a directory in the configuration file.
#	Installing Zabbix will create include directory in /usr/local/etc, unless modified during the compile time.
#
# Mandatory: no
# Default:
# Include=

# Include=/usr/local/etc/zabbix_proxy.general.conf
# Include=/usr/local/etc/zabbix_proxy.conf.d/
# Include=/usr/local/etc/zabbix_proxy.conf.d/*.conf

### Option: SSLCertLocation
#	Location of SSL client certificates.
#	This parameter is used only in web monitoring.
#
# Mandatory: no
# Default:
# SSLCertLocation=${datadir}/zabbix/ssl/certs

### Option: SSLKeyLocation
#	Location of private keys for SSL client certificates.
#	This parameter is used only in web monitoring.
#
# Mandatory: no
# Default:
# SSLKeyLocation=${datadir}/zabbix/ssl/keys

### Option: SSLCALocation
#	Location of certificate authority (CA) files for SSL server certificate verification.
#	If not set, system-wide directory will be used.
#	This parameter is used only in web monitoring.
#
# Mandatory: no
# Default:
# SSLCALocation=

####### LOADABLE MODULES #######

### Option: LoadModulePath
#	Full path to location of proxy modules.
#	Default depends on compilation options.
#
# Mandatory: no
# Default:
# LoadModulePath=${libdir}/modules

### Option: LoadModule
#	Module to load at proxy startup. Modules are used to extend functionality of the proxy.
#	Format: LoadModule=<module.so>
#	The modules must be located in directory specified by LoadModulePath.
#	It is allowed to include multiple LoadModule parameters.
#
# Mandatory: no
# Default:
# LoadModule=

####### TLS-RELATED PARAMETERS #######

### Option: TLSConnect
#	How the proxy should connect to Zabbix server. Used for an active proxy, ignored on a passive proxy.
#	Only one value can be specified:
#		unencrypted - connect without encryption
#		psk         - connect using TLS and a pre-shared key
#		cert        - connect using TLS and a certificate
#
# Mandatory: yes, if TLS certificate or PSK parameters are defined (even for 'unencrypted' connection)
# Default:
# TLSConnect=unencrypted

### Option: TLSAccept
#	What incoming connections to accept from Zabbix server. Used for a passive proxy, ignored on an active proxy.
#	Multiple values can be specified, separated by comma:
#		unencrypted - accept connections without encryption
#		psk         - accept connections secured with TLS and a pre-shared key
#		cert        - accept connections secured with TLS and a certificate
#
# Mandatory: yes, if TLS certificate or PSK parameters are defined (even for 'unencrypted' connection)
# Default:
# TLSAccept=unencrypted

### Option: TLSCAFile
#	Full pathname of a file containing the top-level CA(s) certificates for
#	peer certificate verification.
#
# Mandatory: no
# Default:
# TLSCAFile=

### Option: TLSCRLFile
#	Full pathname of a file containing revoked certificates.
#
# Mandatory: no
# Default:
# TLSCRLFile=

### Option: TLSServerCertIssuer
#      Allowed server certificate issuer.
#
# Mandatory: no
# Default:
# TLSServerCertIssuer=

### Option: TLSServerCertSubject
#      Allowed server certificate subject.
#
# Mandatory: no
# Default:
# TLSServerCertSubject=

### Option: TLSCertFile
#	Full pathname of a file containing the proxy certificate or certificate chain.
#
# Mandatory: no
# Default:
# TLSCertFile=

### Option: TLSKeyFile
#	Full pathname of a file containing the proxy private key.
#
# Mandatory: no
# Default:
# TLSKeyFile=

### Option: TLSPSKIdentity
#	Unique, case sensitive string used to identify the pre-shared key.
#
# Mandatory: no
# Default:
# TLSPSKIdentity=

### Option: TLSPSKFile
#	Full pathname of a file containing the pre-shared key.
#
# Mandatory: no
# Default:
# TLSPSKFile=

TLSConnect=psk
TLSPSKFile=/etc/zabbix/zabbix_proxy.psk
TLSPSKIdentity=$nomeItop

" > /etc/zabbix/zabbix_proxy.conf



        #openssl rand -hex 32 > /etc/zabbix/zabbix_proxy.psk
        echo "$chaveProxy" > /etc/zabbix/zabbix_proxy.psk
        systemctl start zabbix-proxy
        systemctl start zabbix-agent
        systemctl enable zabbix-proxy
        systemctl enable zabbix-agent
	#chave="$(cat /etc/zabbix/zabbix_proxy.psk)"
	echo "-------------------------------------------------"
	echo "Instalação finalizada!"
	echo "-------------------------------------------------"
	echo "Chave informada: $chaveProxy"
	echo "-------------------------------------------------"

  echo "
# This is a configuration file for Zabbix agent daemon (Unix)
# To get more information about Zabbix, visit http://www.zabbix.com

############ GENERAL PARAMETERS #################

### Option: PidFile
#	Name of PID file.
#
# Mandatory: no
# Default:
# PidFile=/tmp/zabbix_agentd.pid

PidFile=/var/run/zabbix/zabbix_agentd.pid

### Option: LogType
#	Specifies where log messages are written to:
#		system  - syslog
#		file    - file specified with LogFile parameter
#		console - standard output
#
# Mandatory: no
# Default:
# LogType=file

### Option: LogFile
#	Log file name for LogType 'file' parameter.
#
# Mandatory: no
# Default:
# LogFile=

LogFile=/var/log/zabbix/zabbix_agentd.log

### Option: LogFileSize
#	Maximum size of log file in MB.
#	0 - disable automatic log rotation.
#
# Mandatory: no
# Range: 0-1024
# Default:
# LogFileSize=1

LogFileSize=10

### Option: DebugLevel
#	Specifies debug level:
#	0 - basic information about starting and stopping of Zabbix processes
#	1 - critical information
#	2 - error information
#	3 - warnings
#	4 - for debugging (produces lots of information)
#	5 - extended debugging (produces even more information)
#
# Mandatory: no
# Range: 0-5
# Default:
# DebugLevel=3

### Option: SourceIP
#	Source IP address for outgoing connections.
#
# Mandatory: no
# Default:
# SourceIP=

### Option: EnableRemoteCommands
#	Whether remote commands from Zabbix server are allowed.
#	0 - not allowed
#	1 - allowed
#
# Mandatory: no
# Default:
EnableRemoteCommands=1

### Option: LogRemoteCommands
#	Enable logging of executed shell commands as warnings.
#	0 - disabled
#	1 - enabled
#
# Mandatory: no
# Default:
# LogRemoteCommands=0

##### Passive checks related

### Option: Server
#	List of comma delimited IP addresses, optionally in CIDR notation, or hostnames of Zabbix servers and Zabbix proxies.
#	Incoming connections will be accepted only from the hosts listed here.
#	If IPv6 support is enabled then '127.0.0.1', '::127.0.0.1', '::ffff:127.0.0.1' are treated equally and '::/0' will allow any IPv4 or IPv6 address.
#	'0.0.0.0/0' can be used to allow any IPv4 address.
#	Example: Server=127.0.0.1,192.168.1.0/24,::1,2001:db8::/32,zabbix.domain
#
# Mandatory: no
# Default:
# Server=

Server=$ipProxy

### Option: ListenPort
#	Agent will listen on this port for connections from the server.
#
# Mandatory: no
# Range: 1024-32767
# Default:
# ListenPort=10050

### Option: ListenIP
#	List of comma delimited IP addresses that the agent should listen on.
#	First IP address is sent to Zabbix server if connecting to it to retrieve list of active checks.
#
# Mandatory: no
# Default:
# ListenIP=0.0.0.0

### Option: StartAgents
#	Number of pre-forked instances of zabbix_agentd that process passive checks.
#	If set to 0, disables passive checks and the agent will not listen on any TCP port.
#
# Mandatory: no
# Range: 0-100
# Default:
# StartAgents=3

##### Active checks related

### Option: ServerActive
#	List of comma delimited IP:port (or hostname:port) pairs of Zabbix servers and Zabbix proxies for active checks.
#	If port is not specified, default port is used.
#	IPv6 addresses must be enclosed in square brackets if port for that host is specified.
#	If port is not specified, square brackets for IPv6 addresses are optional.
#	If this parameter is not specified, active checks are disabled.
#	Example: ServerActive=127.0.0.1:20051,zabbix.domain,[::1]:30051,::1,[12fc::1]
#
# Mandatory: no
# Default:
# ServerActive=

ServerActive=$ipProxy

### Option: Hostname
#	Unique, case sensitive hostname.
#	Required for active checks and must match hostname as configured on the server.
#	Value is acquired from HostnameItem if undefined.
#
# Mandatory: no
# Default:
# Hostname=

Hostname=$nomeItop_$nomeItop

### Option: HostnameItem
#	Item used for generating Hostname if it is undefined. Ignored if Hostname is defined.
#	Does not support UserParameters or aliases.
#
# Mandatory: no
# Default:
# HostnameItem=system.hostname

### Option: HostMetadata
#	Optional parameter that defines host metadata.
#	Host metadata is used at host auto-registration process.
#	An agent will issue an error and not start if the value is over limit of 255 characters.
#	If not defined, value will be acquired from HostMetadataItem.
#
# Mandatory: no
# Range: 0-255 characters
# Default:
# HostMetadata=

### Option: HostMetadataItem
#	Optional parameter that defines an item used for getting host metadata.
#	Host metadata is used at host auto-registration process.
#	During an auto-registration request an agent will log a warning message if
#	the value returned by specified item is over limit of 255 characters.
#	This option is only used when HostMetadata is not defined.
#
# Mandatory: no
# Default:
# HostMetadataItem=

### Option: RefreshActiveChecks
#	How often list of active checks is refreshed, in seconds.
#
# Mandatory: no
# Range: 60-3600
# Default:
# RefreshActiveChecks=120

### Option: BufferSend
#	Do not keep data longer than N seconds in buffer.
#
# Mandatory: no
# Range: 1-3600
# Default:
# BufferSend=5

### Option: BufferSize
#	Maximum number of values in a memory buffer. The agent will send
#	all collected data to Zabbix Server or Proxy if the buffer is full.
#
# Mandatory: no
# Range: 2-65535
# Default:
# BufferSize=100

### Option: MaxLinesPerSecond
#	Maximum number of new lines the agent will send per second to Zabbix Server
#	or Proxy processing 'log' and 'logrt' active checks.
#	The provided value will be overridden by the parameter 'maxlines',
#	provided in 'log' or 'logrt' item keys.
#
# Mandatory: no
# Range: 1-1000
# Default:
# MaxLinesPerSecond=20

############ ADVANCED PARAMETERS #################

### Option: Alias
#	Sets an alias for an item key. It can be used to substitute long and complex item key with a smaller and simpler one.
#	Multiple Alias parameters may be present. Multiple parameters with the same Alias key are not allowed.
#	Different Alias keys may reference the same item key.
#	For example, to retrieve the ID of user 'zabbix':
#	Alias=zabbix.userid:vfs.file.regexp[/etc/passwd,^zabbix:.:([0-9]+),,,,\1]
#	Now shorthand key zabbix.userid may be used to retrieve data.
#	Aliases can be used in HostMetadataItem but not in HostnameItem parameters.
#
# Mandatory: no
# Range:
# Default:

### Option: Timeout
#	Spend no more than Timeout seconds on processing
#
# Mandatory: no
# Range: 1-30
# Default:
Timeout=30

### Option: AllowRoot
#	Allow the agent to run as 'root'. If disabled and the agent is started by 'root', the agent
#	will try to switch to the user specified by the User configuration option instead.
#	Has no effect if started under a regular user.
#	0 - do not allow
#	1 - allow
#
# Mandatory: no
# Default:
# AllowRoot=0

### Option: User
#	Drop privileges to a specific, existing user on the system.
#	Only has effect if run as 'root' and AllowRoot is disabled.
#
# Mandatory: no
# Default:
# User=zabbix

### Option: Include
#	You may include individual files or all files in a directory in the configuration file.
#	Installing Zabbix will create include directory in /usr/local/etc, unless modified during the compile time.
#
# Mandatory: no
# Default:
# Include=

Include=/etc/zabbix/zabbix_agentd.d/*.conf

# Include=/usr/local/etc/zabbix_agentd.userparams.conf
# Include=/usr/local/etc/zabbix_agentd.conf.d/
# Include=/usr/local/etc/zabbix_agentd.conf.d/*.conf

####### USER-DEFINED MONITORED PARAMETERS #######

### Option: UnsafeUserParameters
#	Allow all characters to be passed in arguments to user-defined parameters.
#	The following characters are not allowed:
#
# Mandatory: no
# Range: 0-1
# Default:
# UnsafeUserParameters=0

### Option: UserParameter
#	User-defined parameter to monitor. There can be several user-defined parameters.
#	Format: UserParameter=<key>,<shell command>
#	See 'zabbix_agentd' directory for examples.
#
# Mandatory: no
# Default:
# UserParameter=

####### LOADABLE MODULES #######

### Option: LoadModulePath
#	Full path to location of agent modules.
#	Default depends on compilation options.
#
# Mandatory: no
# Default:
# LoadModulePath=${libdir}/modules

### Option: LoadModule
#	Module to load at agent startup. Modules are used to extend functionality of the agent.
#	Format: LoadModule=<module.so>
#	The modules must be located in directory specified by LoadModulePath.
#	It is allowed to include multiple LoadModule parameters.
#
# Mandatory: no
# Default:
# LoadModule=

####### TLS-RELATED PARAMETERS #######

### Option: TLSConnect
#	How the agent should connect to server or proxy. Used for active checks.
#	Only one value can be specified:
#		unencrypted - connect without encryption
#		psk         - connect using TLS and a pre-shared key
#		cert        - connect using TLS and a certificate
#
# Mandatory: yes, if TLS certificate or PSK parameters are defined (even for 'unencrypted' connection)
# Default:
# TLSConnect=unencrypted

### Option: TLSAccept
#	What incoming connections to accept.
#	Multiple values can be specified, separated by comma:
#		unencrypted - accept connections without encryption
#		psk         - accept connections secured with TLS and a pre-shared key
#		cert        - accept connections secured with TLS and a certificate
#
# Mandatory: yes, if TLS certificate or PSK parameters are defined (even for 'unencrypted' connection)
# Default:
# TLSAccept=unencrypted

### Option: TLSCAFile
#	Full pathname of a file containing the top-level CA(s) certificates for
#	peer certificate verification.
#
# Mandatory: no
# Default:
# TLSCAFile=

### Option: TLSCRLFile
#	Full pathname of a file containing revoked certificates.
#
# Mandatory: no
# Default:
# TLSCRLFile=

### Option: TLSServerCertIssuer
#      Allowed server certificate issuer.
#
# Mandatory: no
# Default:
# TLSServerCertIssuer=

### Option: TLSServerCertSubject
#      Allowed server certificate subject.
#
# Mandatory: no
# Default:
# TLSServerCertSubject=

### Option: TLSCertFile
#	Full pathname of a file containing the agent certificate or certificate chain.
#
# Mandatory: no
# Default:
# TLSCertFile=

### Option: TLSKeyFile
#	Full pathname of a file containing the agent private key.
#
# Mandatory: no
# Default:
# TLSKeyFile=

### Option: TLSPSKIdentity
#	Unique, case sensitive string used to identify the pre-shared key.
#
# Mandatory: no
# Default:
# TLSPSKIdentity=

### Option: TLSPSKFile
#	Full pathname of a file containing the pre-shared key.
#
# Mandatory: no
# Default:
# TLSPSKFile=

  " > /etc/zabbix/zabbix_agentd.conf	

  sudo wget -P /tmp https://app.hit.com.vc/automacao/saltinstallv2.sh --no-check-certificate && sudo chmod +x /tmp/saltinstallv2.sh
  sudo sh /tmp/saltinstallv2.sh

elif [[ $distro == *"CentOS"* ]] && [[ $distro == *"7"* ]];
then
        #rpm -ivh http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-1.el7.centos.noarch.rpm
		rpm -ivh http://repo.zabbix.com/zabbix/4.4/rhel/7/x86_64/zabbix-release-4.4-1.el7.noarch.rpm
        yum install zabbix-proxy-sqlite3-4.4.7 zabbix-get-4.4.7 zabbix-sender-4.4.7 zabbix-agent-4.4.7 net-snmp-utils nmap ntsysv wget curl vim telnet psmisc -y
		#yum install zabbix-proxy-sqlite3-3.4.10 zabbix-get-3.4.10 zabbix-sender-3.4.10 zabbix-agent-3.4.10 net-snmp-utils nmap ntsysv wget curl vim telnet psmisc -y

echo "
# This is a configuration file for Zabbix proxy daemon
# To get more information about Zabbix, visit http://www.zabbix.com

############ GENERAL PARAMETERS #################

### Option: ProxyMode
#	Proxy operating mode.
#	0 - proxy in the active mode
#	1 - proxy in the passive mode
#
# Mandatory: no
# Default:
# ProxyMode=0

### Option: Server
#	IP address (or hostname) of Zabbix server.
#	Active proxy will get configuration data from the server.
#	For a proxy in the passive mode this parameter will be ignored.
#
# Mandatory: yes (if ProxyMode is set to 0)
# Default:
# Server=

Server=hproxy.hit.com.vc

### Option: ServerPort
#	Port of Zabbix trapper on Zabbix server.
#	For a proxy in the passive mode this parameter will be ignored.
#
# Mandatory: no
# Range: 1024-32767
# Default:
# ServerPort=10051

### Option: Hostname
#	Unique, case sensitive Proxy name. Make sure the Proxy name is known to the server!
#	Value is acquired from HostnameItem if undefined.
#
# Mandatory: no
# Default:
# Hostname=

Hostname=$nomeItop

### Option: HostnameItem
#	Item used for generating Hostname if it is undefined.
#	Ignored if Hostname is defined.
#
# Mandatory: no
# Default:
# HostnameItem=system.hostname

### Option: ListenPort
#	Listen port for trapper.
#
# Mandatory: no
# Range: 1024-32767
# Default:
# ListenPort=10051

### Option: SourceIP
#	Source IP address for outgoing connections.
#
# Mandatory: no
# Default:
# SourceIP=

### Option: LogType
#	Specifies where log messages are written to:
#		system  - syslog
#		file    - file specified with LogFile parameter
#		console - standard output
#
# Mandatory: no
# Default:
# LogType=file

### Option: LogFile
#	Log file name for LogType 'file' parameter.
#
# Mandatory: no
# Default:
# LogFile=

LogFile=/var/log/zabbix/zabbix_proxy.log

### Option: LogFileSize
#	Maximum size of log file in MB.
#	0 - disable automatic log rotation.
#
# Mandatory: no
# Range: 0-1024
# Default:
# LogFileSize=1

LogFileSize=10

### Option: DebugLevel
#	Specifies debug level:
#	0 - basic information about starting and stopping of Zabbix processes
#	1 - critical information
#	2 - error information
#	3 - warnings
#	4 - for debugging (produces lots of information)
#	5 - extended debugging (produces even more information)
#
# Mandatory: no
# Range: 0-5
# Default:
# DebugLevel=3

### Option: EnableRemoteCommands
#       Whether remote commands from Zabbix server are allowed.
#       0 - not allowed
#       1 - allowed
#
# Mandatory: no
# Default:
EnableRemoteCommands=1

### Option: LogRemoteCommands
#       Enable logging of executed shell commands as warnings.
#       0 - disabled
#       1 - enabled
#
# Mandatory: no
# Default:
# LogRemoteCommands=0

### Option: PidFile
#	Name of PID file.
#
# Mandatory: no
# Default:
# PidFile=/tmp/zabbix_proxy.pid

PidFile=/var/run/zabbix/zabbix_proxy.pid

### Option: SocketDir
#	IPC socket directory.
#       Directory to store IPC sockets used by internal Zabbix services.
#
# Mandatory: no
# Default:
# SocketDir=/tmp

SocketDir=/var/run/zabbix

### Option: DBHost
#	Database host name.
#	If set to localhost, socket is used for MySQL.
#	If set to empty string, socket is used for PostgreSQL.
#
# Mandatory: no
# Default:
# DBHost=localhost

### Option: DBName
#	Database name.
#	For SQLite3 path to database file must be provided. DBUser and DBPassword are ignored.
#	Warning: do not attempt to use the same database Zabbix server is using.
#
# Mandatory: yes
# Default:
# DBName=

DBName=/tmp/zabbix_proxy.db

### Option: DBSchema
#	Schema name. Used for IBM DB2 and PostgreSQL.
#
# Mandatory: no
# Default:
# DBSchema=

### Option: DBUser
#	Database user. Ignored for SQLite.
#
# Default:
# DBUser=

DBUser=zabbix

### Option: DBPassword
#	Database password. Ignored for SQLite.
#	Comment this line if no password is used.
#
# Mandatory: no
# Default:
# DBPassword=

### Option: DBSocket
#	Path to MySQL socket.
#
# Mandatory: no
# Default:
# DBSocket=/tmp/mysql.sock

# Option: DBPort
#	Database port when not using local socket. Ignored for SQLite.
#
# Mandatory: no
# Default (for MySQL):
# DBPort=3306

######### PROXY SPECIFIC PARAMETERS #############

### Option: ProxyLocalBuffer
#	Proxy will keep data locally for N hours, even if the data have already been synced with the server.
#	This parameter may be used if local data will be used by third party applications.
#
# Mandatory: no
# Range: 0-720
# Default:
# ProxyLocalBuffer=0

### Option: ProxyOfflineBuffer
#	Proxy will keep data for N hours in case if no connectivity with Zabbix Server.
#	Older data will be lost.
#
# Mandatory: no
# Range: 1-720
# Default:
# ProxyOfflineBuffer=1

### Option: HeartbeatFrequency
#	Frequency of heartbeat messages in seconds.
#	Used for monitoring availability of Proxy on server side.
#	0 - heartbeat messages disabled.
#	For a proxy in the passive mode this parameter will be ignored.
#
# Mandatory: no
# Range: 0-3600
# Default:
# HeartbeatFrequency=60

### Option: ConfigFrequency
#	How often proxy retrieves configuration data from Zabbix Server in seconds.
#	For a proxy in the passive mode this parameter will be ignored.
#
# Mandatory: no
# Range: 1-3600*24*7
# Default:
# ConfigFrequency=3600

### Option: DataSenderFrequency
#	Proxy will send collected data to the Server every N seconds.
#	For a proxy in the passive mode this parameter will be ignored.
#
# Mandatory: no
# Range: 1-3600
# Default:
# DataSenderFrequency=1

############ ADVANCED PARAMETERS ################

### Option: StartPollers
#	Number of pre-forked instances of pollers.
#
# Mandatory: no
# Range: 0-1000
# Default:
# StartPollers=5

### Option: StartIPMIPollers
#	Number of pre-forked instances of IPMI pollers.
#       The IPMI manager process is automatically started when at least one IPMI poller is started.
#
# Mandatory: no
# Range: 0-1000
# Default:
# StartIPMIPollers=0

### Option: StartPollersUnreachable
#	Number of pre-forked instances of pollers for unreachable hosts (including IPMI and Java).
#	At least one poller for unreachable hosts must be running if regular, IPMI or Java pollers
#	are started.
#
# Mandatory: no
# Range: 0-1000
# Default:
# StartPollersUnreachable=1

### Option: StartTrappers
#	Number of pre-forked instances of trappers.
#	Trappers accept incoming connections from Zabbix sender and active agents.
#
# Mandatory: no
# Range: 0-1000
# Default:
# StartTrappers=5

### Option: StartPingers
#	Number of pre-forked instances of ICMP pingers.
#
# Mandatory: no
# Range: 0-1000
# Default:
# StartPingers=1

### Option: StartDiscoverers
#	Number of pre-forked instances of discoverers.
#
# Mandatory: no
# Range: 0-250
# Default:
# StartDiscoverers=1

### Option: StartHTTPPollers
#	Number of pre-forked instances of HTTP pollers.
#
# Mandatory: no
# Range: 0-1000
# Default:
# StartHTTPPollers=1

### Option: JavaGateway
#	IP address (or hostname) of Zabbix Java gateway.
#	Only required if Java pollers are started.
#
# Mandatory: no
# Default:
JavaGateway=$ipProxy

### Option: JavaGatewayPort
#	Port that Zabbix Java gateway listens on.
#
# Mandatory: no
# Range: 1024-32767
# Default:
JavaGatewayPort=10052

### Option: StartJavaPollers
#	Number of pre-forked instances of Java pollers.
#
# Mandatory: no
# Range: 0-1000
# Default:
StartJavaPollers=5

### Option: StartVMwareCollectors
#	Number of pre-forked vmware collector instances.
#
# Mandatory: no
# Range: 0-250
# Default:
StartVMwareCollectors=6

### Option: VMwareFrequency
#	How often Zabbix will connect to VMware service to obtain a new data.
#
# Mandatory: no
# Range: 10-86400
# Default:
# VMwareFrequency=60

### Option: VMwarePerfFrequency
#	How often Zabbix will connect to VMware service to obtain performance data.
#
# Mandatory: no
# Range: 10-86400
# Default:
# VMwarePerfFrequency=60

### Option: VMwareCacheSize
#	Size of VMware cache, in bytes.
#	Shared memory size for storing VMware data.
#	Only used if VMware collectors are started.
#
# Mandatory: no
# Range: 256K-2G
# Default:
VMwareCacheSize=8M

### Option: VMwareTimeout
#	Specifies how many seconds vmware collector waits for response from VMware service.
#
# Mandatory: no
# Range: 1-300
# Default:
VMwareTimeout=10

### Option: SNMPTrapperFile
#	Temporary file used for passing data from SNMP trap daemon to the proxy.
#	Must be the same as in zabbix_trap_receiver.pl or SNMPTT configuration file.
#
# Mandatory: no
# Default:
# SNMPTrapperFile=/tmp/zabbix_traps.tmp

SNMPTrapperFile=/var/log/snmptrap/snmptrap.log

### Option: StartSNMPTrapper
#	If 1, SNMP trapper process is started.
#
# Mandatory: no
# Range: 0-1
# Default:
# StartSNMPTrapper=0

### Option: ListenIP
#	List of comma delimited IP addresses that the trapper should listen on.
#	Trapper will listen on all network interfaces if this parameter is missing.
#
# Mandatory: no
# Default:
# ListenIP=0.0.0.0

### Option: HousekeepingFrequency
#	How often Zabbix will perform housekeeping procedure (in hours).
#	Housekeeping is removing outdated information from the database.
#	To prevent Housekeeper from being overloaded, no more than 4 times HousekeepingFrequency
#	hours of outdated information are deleted in one housekeeping cycle.
#	To lower load on proxy startup housekeeping is postponed for 30 minutes after proxy start.
#	With HousekeepingFrequency=0 the housekeeper can be only executed using the runtime control option.
#	In this case the period of outdated information deleted in one housekeeping cycle is 4 times the
#	period since the last housekeeping cycle, but not less than 4 hours and not greater than 4 days.
#
# Mandatory: no
# Range: 0-24
# Default:
# HousekeepingFrequency=1

### Option: CacheSize
#	Size of configuration cache, in bytes.
#	Shared memory size, for storing hosts and items data.
#
# Mandatory: no
# Range: 128K-8G
# Default:
# CacheSize=8M

### Option: StartDBSyncers
#	Number of pre-forked instances of DB Syncers.
#
# Mandatory: no
# Range: 1-100
# Default:
# StartDBSyncers=4

### Option: HistoryCacheSize
#	Size of history cache, in bytes.
#	Shared memory size for storing history data.
#
# Mandatory: no
# Range: 128K-2G
# Default:
# HistoryCacheSize=16M

### Option: HistoryIndexCacheSize
#	Size of history index cache, in bytes.
#	Shared memory size for indexing history cache.
#
# Mandatory: no
# Range: 128K-2G
# Default:
# HistoryIndexCacheSize=4M

### Option: Timeout
#	Specifies how long we wait for agent, SNMP device or external check (in seconds).
#
# Mandatory: no
# Range: 1-30
# Default:
# Timeout=3

Timeout=30

### Option: TrapperTimeout
#	Specifies how many seconds trapper may spend processing new data.
#
# Mandatory: no
# Range: 1-300
# Default:
# TrapperTimeout=300

### Option: UnreachablePeriod
#	After how many seconds of unreachability treat a host as unavailable.
#
# Mandatory: no
# Range: 1-3600
# Default:
# UnreachablePeriod=45

### Option: UnavailableDelay
#	How often host is checked for availability during the unavailability period, in seconds.
#
# Mandatory: no
# Range: 1-3600
# Default:
# UnavailableDelay=60

### Option: UnreachableDelay
#	How often host is checked for availability during the unreachability period, in seconds.
#
# Mandatory: no
# Range: 1-3600
# Default:
# UnreachableDelay=15

### Option: ExternalScripts
#	Full path to location of external scripts.
#	Default depends on compilation options.
#
# Mandatory: no
# Default:
# ExternalScripts=${datadir}/zabbix/externalscripts

ExternalScripts=/usr/lib/zabbix/externalscripts

### Option: FpingLocation
#	Location of fping.
#	Make sure that fping binary has root ownership and SUID flag set.
#
# Mandatory: no
# Default:
# FpingLocation=/usr/sbin/fping

### Option: Fping6Location
#	Location of fping6.
#	Make sure that fping6 binary has root ownership and SUID flag set.
#	Make empty if your fping utility is capable to process IPv6 addresses.
#
# Mandatory: no
# Default:
# Fping6Location=/usr/sbin/fping6

### Option: SSHKeyLocation
#	Location of public and private keys for SSH checks and actions.
#
# Mandatory: no
# Default:
# SSHKeyLocation=

### Option: LogSlowQueries
#	How long a database query may take before being logged (in milliseconds).
#	Only works if DebugLevel set to 3 or 4.
#	0 - don't log slow queries.
#
# Mandatory: no
# Range: 1-3600000
# Default:
# LogSlowQueries=0

LogSlowQueries=3000

### Option: TmpDir
#	Temporary directory.
#
# Mandatory: no
# Default:
# TmpDir=/tmp

### Option: AllowRoot
#	Allow the proxy to run as 'root'. If disabled and the proxy is started by 'root', the proxy
#	will try to switch to the user specified by the User configuration option instead.
#	Has no effect if started under a regular user.
#	0 - do not allow
#	1 - allow
#
# Mandatory: no
# Default:
# AllowRoot=0

### Option: User
#	Drop privileges to a specific, existing user on the system.
#	Only has effect if run as 'root' and AllowRoot is disabled.
#
# Mandatory: no
# Default:
# User=zabbix

### Option: Include
#	You may include individual files or all files in a directory in the configuration file.
#	Installing Zabbix will create include directory in /usr/local/etc, unless modified during the compile time.
#
# Mandatory: no
# Default:
# Include=

# Include=/usr/local/etc/zabbix_proxy.general.conf
# Include=/usr/local/etc/zabbix_proxy.conf.d/
# Include=/usr/local/etc/zabbix_proxy.conf.d/*.conf

### Option: SSLCertLocation
#	Location of SSL client certificates.
#	This parameter is used only in web monitoring.
#
# Mandatory: no
# Default:
# SSLCertLocation=${datadir}/zabbix/ssl/certs

### Option: SSLKeyLocation
#	Location of private keys for SSL client certificates.
#	This parameter is used only in web monitoring.
#
# Mandatory: no
# Default:
# SSLKeyLocation=${datadir}/zabbix/ssl/keys

### Option: SSLCALocation
#	Location of certificate authority (CA) files for SSL server certificate verification.
#	If not set, system-wide directory will be used.
#	This parameter is used only in web monitoring.
#
# Mandatory: no
# Default:
# SSLCALocation=

####### LOADABLE MODULES #######

### Option: LoadModulePath
#	Full path to location of proxy modules.
#	Default depends on compilation options.
#
# Mandatory: no
# Default:
# LoadModulePath=${libdir}/modules

### Option: LoadModule
#	Module to load at proxy startup. Modules are used to extend functionality of the proxy.
#	Format: LoadModule=<module.so>
#	The modules must be located in directory specified by LoadModulePath.
#	It is allowed to include multiple LoadModule parameters.
#
# Mandatory: no
# Default:
# LoadModule=

####### TLS-RELATED PARAMETERS #######

### Option: TLSConnect
#	How the proxy should connect to Zabbix server. Used for an active proxy, ignored on a passive proxy.
#	Only one value can be specified:
#		unencrypted - connect without encryption
#		psk         - connect using TLS and a pre-shared key
#		cert        - connect using TLS and a certificate
#
# Mandatory: yes, if TLS certificate or PSK parameters are defined (even for 'unencrypted' connection)
# Default:
# TLSConnect=unencrypted

### Option: TLSAccept
#	What incoming connections to accept from Zabbix server. Used for a passive proxy, ignored on an active proxy.
#	Multiple values can be specified, separated by comma:
#		unencrypted - accept connections without encryption
#		psk         - accept connections secured with TLS and a pre-shared key
#		cert        - accept connections secured with TLS and a certificate
#
# Mandatory: yes, if TLS certificate or PSK parameters are defined (even for 'unencrypted' connection)
# Default:
# TLSAccept=unencrypted

### Option: TLSCAFile
#	Full pathname of a file containing the top-level CA(s) certificates for
#	peer certificate verification.
#
# Mandatory: no
# Default:
# TLSCAFile=

### Option: TLSCRLFile
#	Full pathname of a file containing revoked certificates.
#
# Mandatory: no
# Default:
# TLSCRLFile=

### Option: TLSServerCertIssuer
#      Allowed server certificate issuer.
#
# Mandatory: no
# Default:
# TLSServerCertIssuer=

### Option: TLSServerCertSubject
#      Allowed server certificate subject.
#
# Mandatory: no
# Default:
# TLSServerCertSubject=

### Option: TLSCertFile
#	Full pathname of a file containing the proxy certificate or certificate chain.
#
# Mandatory: no
# Default:
# TLSCertFile=

### Option: TLSKeyFile
#	Full pathname of a file containing the proxy private key.
#
# Mandatory: no
# Default:
# TLSKeyFile=

### Option: TLSPSKIdentity
#	Unique, case sensitive string used to identify the pre-shared key.
#
# Mandatory: no
# Default:
# TLSPSKIdentity=

### Option: TLSPSKFile
#	Full pathname of a file containing the pre-shared key.
#
# Mandatory: no
# Default:
# TLSPSKFile=

TLSConnect=psk
TLSPSKFile=/etc/zabbix/zabbix_proxy.psk
TLSPSKIdentity=$nomeItop

" > /etc/zabbix/zabbix_proxy.conf



        #openssl rand -hex 32 > /etc/zabbix/zabbix_proxy.psk
        echo "$chaveProxy" > /etc/zabbix/zabbix_proxy.psk
        systemctl start zabbix-proxy
        systemctl start zabbix-agent
        systemctl enable zabbix-proxy
        systemctl enable zabbix-agent
	#chave="$(cat /etc/zabbix/zabbix_proxy.psk)"
	echo "-------------------------------------------------"
	echo "Instalação finalizada!"
	echo "-------------------------------------------------"
	echo "Chave informada: $chaveProxy"
	echo "-------------------------------------------------"

  echo "
# This is a configuration file for Zabbix agent daemon (Unix)
# To get more information about Zabbix, visit http://www.zabbix.com

############ GENERAL PARAMETERS #################

### Option: PidFile
#	Name of PID file.
#
# Mandatory: no
# Default:
# PidFile=/tmp/zabbix_agentd.pid

PidFile=/var/run/zabbix/zabbix_agentd.pid

### Option: LogType
#	Specifies where log messages are written to:
#		system  - syslog
#		file    - file specified with LogFile parameter
#		console - standard output
#
# Mandatory: no
# Default:
# LogType=file

### Option: LogFile
#	Log file name for LogType 'file' parameter.
#
# Mandatory: no
# Default:
# LogFile=

LogFile=/var/log/zabbix/zabbix_agentd.log

### Option: LogFileSize
#	Maximum size of log file in MB.
#	0 - disable automatic log rotation.
#
# Mandatory: no
# Range: 0-1024
# Default:
# LogFileSize=1

LogFileSize=10

### Option: DebugLevel
#	Specifies debug level:
#	0 - basic information about starting and stopping of Zabbix processes
#	1 - critical information
#	2 - error information
#	3 - warnings
#	4 - for debugging (produces lots of information)
#	5 - extended debugging (produces even more information)
#
# Mandatory: no
# Range: 0-5
# Default:
# DebugLevel=3

### Option: SourceIP
#	Source IP address for outgoing connections.
#
# Mandatory: no
# Default:
# SourceIP=

### Option: EnableRemoteCommands
#	Whether remote commands from Zabbix server are allowed.
#	0 - not allowed
#	1 - allowed
#
# Mandatory: no
# Default:
EnableRemoteCommands=1

### Option: LogRemoteCommands
#	Enable logging of executed shell commands as warnings.
#	0 - disabled
#	1 - enabled
#
# Mandatory: no
# Default:
# LogRemoteCommands=0

##### Passive checks related

### Option: Server
#	List of comma delimited IP addresses, optionally in CIDR notation, or hostnames of Zabbix servers and Zabbix proxies.
#	Incoming connections will be accepted only from the hosts listed here.
#	If IPv6 support is enabled then '127.0.0.1', '::127.0.0.1', '::ffff:127.0.0.1' are treated equally and '::/0' will allow any IPv4 or IPv6 address.
#	'0.0.0.0/0' can be used to allow any IPv4 address.
#	Example: Server=127.0.0.1,192.168.1.0/24,::1,2001:db8::/32,zabbix.domain
#
# Mandatory: no
# Default:
# Server=

Server=$ipProxy

### Option: ListenPort
#	Agent will listen on this port for connections from the server.
#
# Mandatory: no
# Range: 1024-32767
# Default:
# ListenPort=10050

### Option: ListenIP
#	List of comma delimited IP addresses that the agent should listen on.
#	First IP address is sent to Zabbix server if connecting to it to retrieve list of active checks.
#
# Mandatory: no
# Default:
# ListenIP=0.0.0.0

### Option: StartAgents
#	Number of pre-forked instances of zabbix_agentd that process passive checks.
#	If set to 0, disables passive checks and the agent will not listen on any TCP port.
#
# Mandatory: no
# Range: 0-100
# Default:
# StartAgents=3

##### Active checks related

### Option: ServerActive
#	List of comma delimited IP:port (or hostname:port) pairs of Zabbix servers and Zabbix proxies for active checks.
#	If port is not specified, default port is used.
#	IPv6 addresses must be enclosed in square brackets if port for that host is specified.
#	If port is not specified, square brackets for IPv6 addresses are optional.
#	If this parameter is not specified, active checks are disabled.
#	Example: ServerActive=127.0.0.1:20051,zabbix.domain,[::1]:30051,::1,[12fc::1]
#
# Mandatory: no
# Default:
# ServerActive=

ServerActive=$ipProxy

### Option: Hostname
#	Unique, case sensitive hostname.
#	Required for active checks and must match hostname as configured on the server.
#	Value is acquired from HostnameItem if undefined.
#
# Mandatory: no
# Default:
# Hostname=

Hostname=$nomeItop_$nomeItop

### Option: HostnameItem
#	Item used for generating Hostname if it is undefined. Ignored if Hostname is defined.
#	Does not support UserParameters or aliases.
#
# Mandatory: no
# Default:
# HostnameItem=system.hostname

### Option: HostMetadata
#	Optional parameter that defines host metadata.
#	Host metadata is used at host auto-registration process.
#	An agent will issue an error and not start if the value is over limit of 255 characters.
#	If not defined, value will be acquired from HostMetadataItem.
#
# Mandatory: no
# Range: 0-255 characters
# Default:
# HostMetadata=

### Option: HostMetadataItem
#	Optional parameter that defines an item used for getting host metadata.
#	Host metadata is used at host auto-registration process.
#	During an auto-registration request an agent will log a warning message if
#	the value returned by specified item is over limit of 255 characters.
#	This option is only used when HostMetadata is not defined.
#
# Mandatory: no
# Default:
# HostMetadataItem=

### Option: RefreshActiveChecks
#	How often list of active checks is refreshed, in seconds.
#
# Mandatory: no
# Range: 60-3600
# Default:
# RefreshActiveChecks=120

### Option: BufferSend
#	Do not keep data longer than N seconds in buffer.
#
# Mandatory: no
# Range: 1-3600
# Default:
# BufferSend=5

### Option: BufferSize
#	Maximum number of values in a memory buffer. The agent will send
#	all collected data to Zabbix Server or Proxy if the buffer is full.
#
# Mandatory: no
# Range: 2-65535
# Default:
# BufferSize=100

### Option: MaxLinesPerSecond
#	Maximum number of new lines the agent will send per second to Zabbix Server
#	or Proxy processing 'log' and 'logrt' active checks.
#	The provided value will be overridden by the parameter 'maxlines',
#	provided in 'log' or 'logrt' item keys.
#
# Mandatory: no
# Range: 1-1000
# Default:
# MaxLinesPerSecond=20

############ ADVANCED PARAMETERS #################

### Option: Alias
#	Sets an alias for an item key. It can be used to substitute long and complex item key with a smaller and simpler one.
#	Multiple Alias parameters may be present. Multiple parameters with the same Alias key are not allowed.
#	Different Alias keys may reference the same item key.
#	For example, to retrieve the ID of user 'zabbix':
#	Alias=zabbix.userid:vfs.file.regexp[/etc/passwd,^zabbix:.:([0-9]+),,,,\1]
#	Now shorthand key zabbix.userid may be used to retrieve data.
#	Aliases can be used in HostMetadataItem but not in HostnameItem parameters.
#
# Mandatory: no
# Range:
# Default:

### Option: Timeout
#	Spend no more than Timeout seconds on processing
#
# Mandatory: no
# Range: 1-30
# Default:
Timeout=30

### Option: AllowRoot
#	Allow the agent to run as 'root'. If disabled and the agent is started by 'root', the agent
#	will try to switch to the user specified by the User configuration option instead.
#	Has no effect if started under a regular user.
#	0 - do not allow
#	1 - allow
#
# Mandatory: no
# Default:
# AllowRoot=0

### Option: User
#	Drop privileges to a specific, existing user on the system.
#	Only has effect if run as 'root' and AllowRoot is disabled.
#
# Mandatory: no
# Default:
# User=zabbix

### Option: Include
#	You may include individual files or all files in a directory in the configuration file.
#	Installing Zabbix will create include directory in /usr/local/etc, unless modified during the compile time.
#
# Mandatory: no
# Default:
# Include=

Include=/etc/zabbix/zabbix_agentd.d/*.conf

# Include=/usr/local/etc/zabbix_agentd.userparams.conf
# Include=/usr/local/etc/zabbix_agentd.conf.d/
# Include=/usr/local/etc/zabbix_agentd.conf.d/*.conf

####### USER-DEFINED MONITORED PARAMETERS #######

### Option: UnsafeUserParameters
#	Allow all characters to be passed in arguments to user-defined parameters.
#	The following characters are not allowed:
#
# Mandatory: no
# Range: 0-1
# Default:
# UnsafeUserParameters=0

### Option: UserParameter
#	User-defined parameter to monitor. There can be several user-defined parameters.
#	Format: UserParameter=<key>,<shell command>
#	See 'zabbix_agentd' directory for examples.
#
# Mandatory: no
# Default:
# UserParameter=

####### LOADABLE MODULES #######

### Option: LoadModulePath
#	Full path to location of agent modules.
#	Default depends on compilation options.
#
# Mandatory: no
# Default:
# LoadModulePath=${libdir}/modules

### Option: LoadModule
#	Module to load at agent startup. Modules are used to extend functionality of the agent.
#	Format: LoadModule=<module.so>
#	The modules must be located in directory specified by LoadModulePath.
#	It is allowed to include multiple LoadModule parameters.
#
# Mandatory: no
# Default:
# LoadModule=

####### TLS-RELATED PARAMETERS #######

### Option: TLSConnect
#	How the agent should connect to server or proxy. Used for active checks.
#	Only one value can be specified:
#		unencrypted - connect without encryption
#		psk         - connect using TLS and a pre-shared key
#		cert        - connect using TLS and a certificate
#
# Mandatory: yes, if TLS certificate or PSK parameters are defined (even for 'unencrypted' connection)
# Default:
# TLSConnect=unencrypted

### Option: TLSAccept
#	What incoming connections to accept.
#	Multiple values can be specified, separated by comma:
#		unencrypted - accept connections without encryption
#		psk         - accept connections secured with TLS and a pre-shared key
#		cert        - accept connections secured with TLS and a certificate
#
# Mandatory: yes, if TLS certificate or PSK parameters are defined (even for 'unencrypted' connection)
# Default:
# TLSAccept=unencrypted

### Option: TLSCAFile
#	Full pathname of a file containing the top-level CA(s) certificates for
#	peer certificate verification.
#
# Mandatory: no
# Default:
# TLSCAFile=

### Option: TLSCRLFile
#	Full pathname of a file containing revoked certificates.
#
# Mandatory: no
# Default:
# TLSCRLFile=

### Option: TLSServerCertIssuer
#      Allowed server certificate issuer.
#
# Mandatory: no
# Default:
# TLSServerCertIssuer=

### Option: TLSServerCertSubject
#      Allowed server certificate subject.
#
# Mandatory: no
# Default:
# TLSServerCertSubject=

### Option: TLSCertFile
#	Full pathname of a file containing the agent certificate or certificate chain.
#
# Mandatory: no
# Default:
# TLSCertFile=

### Option: TLSKeyFile
#	Full pathname of a file containing the agent private key.
#
# Mandatory: no
# Default:
# TLSKeyFile=

### Option: TLSPSKIdentity
#	Unique, case sensitive string used to identify the pre-shared key.
#
# Mandatory: no
# Default:
# TLSPSKIdentity=

### Option: TLSPSKFile
#	Full pathname of a file containing the pre-shared key.
#
# Mandatory: no
# Default:
# TLSPSKFile=

  " > /etc/zabbix/zabbix_agentd.conf	

  sudo wget -P /tmp https://app.hit.com.vc/automacao/saltinstallv2.sh --no-check-certificate && sudo chmod +x /tmp/saltinstallv2.sh
  sudo sh /tmp/saltinstallv2.sh

elif [[ $distro == *"CentOS"* ]] && [[ $distro == *"6"* ]];
then
		rpm -ivh http://repo.zabbix.com/zabbix/4.4/rhel/6/x86_64/zabbix-release-4.4-1.el6.noarch.rpm
        #rpm -ivh http://repo.zabbix.com/zabbix/3.4/rhel/6/x86_64/zabbix-release-3.4-1.el6.noarch.rpm
        yum install zabbix-proxy-sqlite3-4.4.7 zabbix-get-4.4.7 zabbix-sender-4.4.7 zabbix-agent-4.4.7 net-snmp-utils nmap ntsysv wget curl vim telnet psmisc -y
		#yum install zabbix-proxy-sqlite3-3.4.10 zabbix-get-3.4.10 zabbix-sender-3.4.10 zabbix-agent-3.4.10 net-snmp-utils nmap ntsysv wget curl vim telnet psmisc -y

echo "
# This is a configuration file for Zabbix proxy daemon
# To get more information about Zabbix, visit http://www.zabbix.com

############ GENERAL PARAMETERS #################

### Option: ProxyMode
#	Proxy operating mode.
#	0 - proxy in the active mode
#	1 - proxy in the passive mode
#
# Mandatory: no
# Default:
# ProxyMode=0

### Option: Server
#	IP address (or hostname) of Zabbix server.
#	Active proxy will get configuration data from the server.
#	For a proxy in the passive mode this parameter will be ignored.
#
# Mandatory: yes (if ProxyMode is set to 0)
# Default:
# Server=

Server=srv-zabbix01.visualsystems.com.br

### Option: ServerPort
#	Port of Zabbix trapper on Zabbix server.
#	For a proxy in the passive mode this parameter will be ignored.
#
# Mandatory: no
# Range: 1024-32767
# Default:
# ServerPort=10051

### Option: Hostname
#	Unique, case sensitive Proxy name. Make sure the Proxy name is known to the server!
#	Value is acquired from HostnameItem if undefined.
#
# Mandatory: no
# Default:
# Hostname=

Hostname=$nomeItop

### Option: HostnameItem
#	Item used for generating Hostname if it is undefined.
#	Ignored if Hostname is defined.
#
# Mandatory: no
# Default:
# HostnameItem=system.hostname

### Option: ListenPort
#	Listen port for trapper.
#
# Mandatory: no
# Range: 1024-32767
# Default:
# ListenPort=10051

### Option: SourceIP
#	Source IP address for outgoing connections.
#
# Mandatory: no
# Default:
# SourceIP=

### Option: LogType
#	Specifies where log messages are written to:
#		system  - syslog
#		file    - file specified with LogFile parameter
#		console - standard output
#
# Mandatory: no
# Default:
# LogType=file

### Option: LogFile
#	Log file name for LogType 'file' parameter.
#
# Mandatory: no
# Default:
# LogFile=

LogFile=/var/log/zabbix/zabbix_proxy.log

### Option: LogFileSize
#	Maximum size of log file in MB.
#	0 - disable automatic log rotation.
#
# Mandatory: no
# Range: 0-1024
# Default:
# LogFileSize=1

LogFileSize=10

### Option: DebugLevel
#	Specifies debug level:
#	0 - basic information about starting and stopping of Zabbix processes
#	1 - critical information
#	2 - error information
#	3 - warnings
#	4 - for debugging (produces lots of information)
#	5 - extended debugging (produces even more information)
#
# Mandatory: no
# Range: 0-5
# Default:
# DebugLevel=3

### Option: EnableRemoteCommands
#       Whether remote commands from Zabbix server are allowed.
#       0 - not allowed
#       1 - allowed
#
# Mandatory: no
# Default:
EnableRemoteCommands=1

### Option: LogRemoteCommands
#       Enable logging of executed shell commands as warnings.
#       0 - disabled
#       1 - enabled
#
# Mandatory: no
# Default:
# LogRemoteCommands=0

### Option: PidFile
#	Name of PID file.
#
# Mandatory: no
# Default:
# PidFile=/tmp/zabbix_proxy.pid

PidFile=/var/run/zabbix/zabbix_proxy.pid

### Option: SocketDir
#	IPC socket directory.
#       Directory to store IPC sockets used by internal Zabbix services.
#
# Mandatory: no
# Default:
# SocketDir=/tmp

SocketDir=/var/run/zabbix

### Option: DBHost
#	Database host name.
#	If set to localhost, socket is used for MySQL.
#	If set to empty string, socket is used for PostgreSQL.
#
# Mandatory: no
# Default:
# DBHost=localhost

### Option: DBName
#	Database name.
#	For SQLite3 path to database file must be provided. DBUser and DBPassword are ignored.
#	Warning: do not attempt to use the same database Zabbix server is using.
#
# Mandatory: yes
# Default:
# DBName=

DBName=/tmp/zabbix_proxy.db

### Option: DBSchema
#	Schema name. Used for IBM DB2 and PostgreSQL.
#
# Mandatory: no
# Default:
# DBSchema=

### Option: DBUser
#	Database user. Ignored for SQLite.
#
# Default:
# DBUser=

DBUser=zabbix

### Option: DBPassword
#	Database password. Ignored for SQLite.
#	Comment this line if no password is used.
#
# Mandatory: no
# Default:
# DBPassword=

### Option: DBSocket
#	Path to MySQL socket.
#
# Mandatory: no
# Default:
# DBSocket=/tmp/mysql.sock

# Option: DBPort
#	Database port when not using local socket. Ignored for SQLite.
#
# Mandatory: no
# Default (for MySQL):
# DBPort=3306

######### PROXY SPECIFIC PARAMETERS #############

### Option: ProxyLocalBuffer
#	Proxy will keep data locally for N hours, even if the data have already been synced with the server.
#	This parameter may be used if local data will be used by third party applications.
#
# Mandatory: no
# Range: 0-720
# Default:
# ProxyLocalBuffer=0

### Option: ProxyOfflineBuffer
#	Proxy will keep data for N hours in case if no connectivity with Zabbix Server.
#	Older data will be lost.
#
# Mandatory: no
# Range: 1-720
# Default:
# ProxyOfflineBuffer=1

### Option: HeartbeatFrequency
#	Frequency of heartbeat messages in seconds.
#	Used for monitoring availability of Proxy on server side.
#	0 - heartbeat messages disabled.
#	For a proxy in the passive mode this parameter will be ignored.
#
# Mandatory: no
# Range: 0-3600
# Default:
# HeartbeatFrequency=60

### Option: ConfigFrequency
#	How often proxy retrieves configuration data from Zabbix Server in seconds.
#	For a proxy in the passive mode this parameter will be ignored.
#
# Mandatory: no
# Range: 1-3600*24*7
# Default:
# ConfigFrequency=3600

### Option: DataSenderFrequency
#	Proxy will send collected data to the Server every N seconds.
#	For a proxy in the passive mode this parameter will be ignored.
#
# Mandatory: no
# Range: 1-3600
# Default:
# DataSenderFrequency=1

############ ADVANCED PARAMETERS ################

### Option: StartPollers
#	Number of pre-forked instances of pollers.
#
# Mandatory: no
# Range: 0-1000
# Default:
# StartPollers=5

### Option: StartIPMIPollers
#	Number of pre-forked instances of IPMI pollers.
#       The IPMI manager process is automatically started when at least one IPMI poller is started.
#
# Mandatory: no
# Range: 0-1000
# Default:
# StartIPMIPollers=0

### Option: StartPollersUnreachable
#	Number of pre-forked instances of pollers for unreachable hosts (including IPMI and Java).
#	At least one poller for unreachable hosts must be running if regular, IPMI or Java pollers
#	are started.
#
# Mandatory: no
# Range: 0-1000
# Default:
# StartPollersUnreachable=1

### Option: StartTrappers
#	Number of pre-forked instances of trappers.
#	Trappers accept incoming connections from Zabbix sender and active agents.
#
# Mandatory: no
# Range: 0-1000
# Default:
# StartTrappers=5

### Option: StartPingers
#	Number of pre-forked instances of ICMP pingers.
#
# Mandatory: no
# Range: 0-1000
# Default:
# StartPingers=1

### Option: StartDiscoverers
#	Number of pre-forked instances of discoverers.
#
# Mandatory: no
# Range: 0-250
# Default:
# StartDiscoverers=1

### Option: StartHTTPPollers
#	Number of pre-forked instances of HTTP pollers.
#
# Mandatory: no
# Range: 0-1000
# Default:
# StartHTTPPollers=1

### Option: JavaGateway
#	IP address (or hostname) of Zabbix Java gateway.
#	Only required if Java pollers are started.
#
# Mandatory: no
# Default:
# JavaGateway=

### Option: JavaGatewayPort
#	Port that Zabbix Java gateway listens on.
#
# Mandatory: no
# Range: 1024-32767
# Default:
# JavaGatewayPort=10052

### Option: StartJavaPollers
#	Number of pre-forked instances of Java pollers.
#
# Mandatory: no
# Range: 0-1000
# Default:
# StartJavaPollers=0

### Option: StartVMwareCollectors
#	Number of pre-forked vmware collector instances.
#
# Mandatory: no
# Range: 0-250
# Default:
StartVMwareCollectors=6

### Option: VMwareFrequency
#	How often Zabbix will connect to VMware service to obtain a new data.
#
# Mandatory: no
# Range: 10-86400
# Default:
# VMwareFrequency=60

### Option: VMwarePerfFrequency
#	How often Zabbix will connect to VMware service to obtain performance data.
#
# Mandatory: no
# Range: 10-86400
# Default:
# VMwarePerfFrequency=60

### Option: VMwareCacheSize
#	Size of VMware cache, in bytes.
#	Shared memory size for storing VMware data.
#	Only used if VMware collectors are started.
#
# Mandatory: no
# Range: 256K-2G
# Default:
VMwareCacheSize=8M

### Option: VMwareTimeout
#	Specifies how many seconds vmware collector waits for response from VMware service.
#
# Mandatory: no
# Range: 1-300
# Default:
VMwareTimeout=10

### Option: SNMPTrapperFile
#	Temporary file used for passing data from SNMP trap daemon to the proxy.
#	Must be the same as in zabbix_trap_receiver.pl or SNMPTT configuration file.
#
# Mandatory: no
# Default:
# SNMPTrapperFile=/tmp/zabbix_traps.tmp

SNMPTrapperFile=/var/log/snmptrap/snmptrap.log

### Option: StartSNMPTrapper
#	If 1, SNMP trapper process is started.
#
# Mandatory: no
# Range: 0-1
# Default:
# StartSNMPTrapper=0

### Option: ListenIP
#	List of comma delimited IP addresses that the trapper should listen on.
#	Trapper will listen on all network interfaces if this parameter is missing.
#
# Mandatory: no
# Default:
# ListenIP=0.0.0.0

### Option: HousekeepingFrequency
#	How often Zabbix will perform housekeeping procedure (in hours).
#	Housekeeping is removing outdated information from the database.
#	To prevent Housekeeper from being overloaded, no more than 4 times HousekeepingFrequency
#	hours of outdated information are deleted in one housekeeping cycle.
#	To lower load on proxy startup housekeeping is postponed for 30 minutes after proxy start.
#	With HousekeepingFrequency=0 the housekeeper can be only executed using the runtime control option.
#	In this case the period of outdated information deleted in one housekeeping cycle is 4 times the
#	period since the last housekeeping cycle, but not less than 4 hours and not greater than 4 days.
#
# Mandatory: no
# Range: 0-24
# Default:
# HousekeepingFrequency=1

### Option: CacheSize
#	Size of configuration cache, in bytes.
#	Shared memory size, for storing hosts and items data.
#
# Mandatory: no
# Range: 128K-8G
# Default:
# CacheSize=8M

### Option: StartDBSyncers
#	Number of pre-forked instances of DB Syncers.
#
# Mandatory: no
# Range: 1-100
# Default:
# StartDBSyncers=4

### Option: HistoryCacheSize
#	Size of history cache, in bytes.
#	Shared memory size for storing history data.
#
# Mandatory: no
# Range: 128K-2G
# Default:
# HistoryCacheSize=16M

### Option: HistoryIndexCacheSize
#	Size of history index cache, in bytes.
#	Shared memory size for indexing history cache.
#
# Mandatory: no
# Range: 128K-2G
# Default:
# HistoryIndexCacheSize=4M

### Option: Timeout
#	Specifies how long we wait for agent, SNMP device or external check (in seconds).
#
# Mandatory: no
# Range: 1-30
# Default:
# Timeout=3

Timeout=30

### Option: TrapperTimeout
#	Specifies how many seconds trapper may spend processing new data.
#
# Mandatory: no
# Range: 1-300
# Default:
# TrapperTimeout=300

### Option: UnreachablePeriod
#	After how many seconds of unreachability treat a host as unavailable.
#
# Mandatory: no
# Range: 1-3600
# Default:
# UnreachablePeriod=45

### Option: UnavailableDelay
#	How often host is checked for availability during the unavailability period, in seconds.
#
# Mandatory: no
# Range: 1-3600
# Default:
# UnavailableDelay=60

### Option: UnreachableDelay
#	How often host is checked for availability during the unreachability period, in seconds.
#
# Mandatory: no
# Range: 1-3600
# Default:
# UnreachableDelay=15

### Option: ExternalScripts
#	Full path to location of external scripts.
#	Default depends on compilation options.
#
# Mandatory: no
# Default:
# ExternalScripts=${datadir}/zabbix/externalscripts

ExternalScripts=/usr/lib/zabbix/externalscripts

### Option: FpingLocation
#	Location of fping.
#	Make sure that fping binary has root ownership and SUID flag set.
#
# Mandatory: no
# Default:
# FpingLocation=/usr/sbin/fping

### Option: Fping6Location
#	Location of fping6.
#	Make sure that fping6 binary has root ownership and SUID flag set.
#	Make empty if your fping utility is capable to process IPv6 addresses.
#
# Mandatory: no
# Default:
# Fping6Location=/usr/sbin/fping6

### Option: SSHKeyLocation
#	Location of public and private keys for SSH checks and actions.
#
# Mandatory: no
# Default:
# SSHKeyLocation=

### Option: LogSlowQueries
#	How long a database query may take before being logged (in milliseconds).
#	Only works if DebugLevel set to 3 or 4.
#	0 - don't log slow queries.
#
# Mandatory: no
# Range: 1-3600000
# Default:
# LogSlowQueries=0

LogSlowQueries=3000

### Option: TmpDir
#	Temporary directory.
#
# Mandatory: no
# Default:
# TmpDir=/tmp

### Option: AllowRoot
#	Allow the proxy to run as 'root'. If disabled and the proxy is started by 'root', the proxy
#	will try to switch to the user specified by the User configuration option instead.
#	Has no effect if started under a regular user.
#	0 - do not allow
#	1 - allow
#
# Mandatory: no
# Default:
# AllowRoot=0

### Option: User
#	Drop privileges to a specific, existing user on the system.
#	Only has effect if run as 'root' and AllowRoot is disabled.
#
# Mandatory: no
# Default:
# User=zabbix

### Option: Include
#	You may include individual files or all files in a directory in the configuration file.
#	Installing Zabbix will create include directory in /usr/local/etc, unless modified during the compile time.
#
# Mandatory: no
# Default:
# Include=

# Include=/usr/local/etc/zabbix_proxy.general.conf
# Include=/usr/local/etc/zabbix_proxy.conf.d/
# Include=/usr/local/etc/zabbix_proxy.conf.d/*.conf

### Option: SSLCertLocation
#	Location of SSL client certificates.
#	This parameter is used only in web monitoring.
#
# Mandatory: no
# Default:
# SSLCertLocation=${datadir}/zabbix/ssl/certs

### Option: SSLKeyLocation
#	Location of private keys for SSL client certificates.
#	This parameter is used only in web monitoring.
#
# Mandatory: no
# Default:
# SSLKeyLocation=${datadir}/zabbix/ssl/keys

### Option: SSLCALocation
#	Location of certificate authority (CA) files for SSL server certificate verification.
#	If not set, system-wide directory will be used.
#	This parameter is used only in web monitoring.
#
# Mandatory: no
# Default:
# SSLCALocation=

####### LOADABLE MODULES #######

### Option: LoadModulePath
#	Full path to location of proxy modules.
#	Default depends on compilation options.
#
# Mandatory: no
# Default:
# LoadModulePath=${libdir}/modules

### Option: LoadModule
#	Module to load at proxy startup. Modules are used to extend functionality of the proxy.
#	Format: LoadModule=<module.so>
#	The modules must be located in directory specified by LoadModulePath.
#	It is allowed to include multiple LoadModule parameters.
#
# Mandatory: no
# Default:
# LoadModule=

####### TLS-RELATED PARAMETERS #######

### Option: TLSConnect
#	How the proxy should connect to Zabbix server. Used for an active proxy, ignored on a passive proxy.
#	Only one value can be specified:
#		unencrypted - connect without encryption
#		psk         - connect using TLS and a pre-shared key
#		cert        - connect using TLS and a certificate
#
# Mandatory: yes, if TLS certificate or PSK parameters are defined (even for 'unencrypted' connection)
# Default:
# TLSConnect=unencrypted

### Option: TLSAccept
#	What incoming connections to accept from Zabbix server. Used for a passive proxy, ignored on an active proxy.
#	Multiple values can be specified, separated by comma:
#		unencrypted - accept connections without encryption
#		psk         - accept connections secured with TLS and a pre-shared key
#		cert        - accept connections secured with TLS and a certificate
#
# Mandatory: yes, if TLS certificate or PSK parameters are defined (even for 'unencrypted' connection)
# Default:
# TLSAccept=unencrypted

### Option: TLSCAFile
#	Full pathname of a file containing the top-level CA(s) certificates for
#	peer certificate verification.
#
# Mandatory: no
# Default:
# TLSCAFile=

### Option: TLSCRLFile
#	Full pathname of a file containing revoked certificates.
#
# Mandatory: no
# Default:
# TLSCRLFile=

### Option: TLSServerCertIssuer
#      Allowed server certificate issuer.
#
# Mandatory: no
# Default:
# TLSServerCertIssuer=

### Option: TLSServerCertSubject
#      Allowed server certificate subject.
#
# Mandatory: no
# Default:
# TLSServerCertSubject=

### Option: TLSCertFile
#	Full pathname of a file containing the proxy certificate or certificate chain.
#
# Mandatory: no
# Default:
# TLSCertFile=

### Option: TLSKeyFile
#	Full pathname of a file containing the proxy private key.
#
# Mandatory: no
# Default:
# TLSKeyFile=

### Option: TLSPSKIdentity
#	Unique, case sensitive string used to identify the pre-shared key.
#
# Mandatory: no
# Default:
# TLSPSKIdentity=

### Option: TLSPSKFile
#	Full pathname of a file containing the pre-shared key.
#
# Mandatory: no
# Default:
# TLSPSKFile=

TLSConnect=psk
TLSPSKFile=/etc/zabbix/zabbix_proxy.psk
TLSPSKIdentity=$nomeItop

" > /etc/zabbix/zabbix_proxy.conf

        #openssl rand -hex 32 > /etc/zabbix/zabbix_proxy.psk
	echo "$chaveProxy" > /etc/zabbix/zabbix_proxy.psk
        service zabbix-proxy start
        service zabbix-agent start
        sudo chkconfig zabbix-agent on
        sudo chkconfig zabbix-proxy on
	#chave="$(cat /etc/zabbix/zabbix_proxy.psk)"
	echo "----------------------------------------------"
	echo "Instalação finalizada!"
	echo "----------------------------------------------"
	echo "Chave informada: $chaveProxy"
	echo "----------------------------------------------"

  echo "
# This is a configuration file for Zabbix agent daemon (Unix)
# To get more information about Zabbix, visit http://www.zabbix.com

############ GENERAL PARAMETERS #################

### Option: PidFile
#	Name of PID file.
#
# Mandatory: no
# Default:
# PidFile=/tmp/zabbix_agentd.pid

PidFile=/var/run/zabbix/zabbix_agentd.pid

### Option: LogType
#	Specifies where log messages are written to:
#		system  - syslog
#		file    - file specified with LogFile parameter
#		console - standard output
#
# Mandatory: no
# Default:
# LogType=file

### Option: LogFile
#	Log file name for LogType 'file' parameter.
#
# Mandatory: no
# Default:
# LogFile=

LogFile=/var/log/zabbix/zabbix_agentd.log

### Option: LogFileSize
#	Maximum size of log file in MB.
#	0 - disable automatic log rotation.
#
# Mandatory: no
# Range: 0-1024
# Default:
# LogFileSize=1

LogFileSize=10

### Option: DebugLevel
#	Specifies debug level:
#	0 - basic information about starting and stopping of Zabbix processes
#	1 - critical information
#	2 - error information
#	3 - warnings
#	4 - for debugging (produces lots of information)
#	5 - extended debugging (produces even more information)
#
# Mandatory: no
# Range: 0-5
# Default:
# DebugLevel=3

### Option: SourceIP
#	Source IP address for outgoing connections.
#
# Mandatory: no
# Default:
# SourceIP=

### Option: EnableRemoteCommands
#	Whether remote commands from Zabbix server are allowed.
#	0 - not allowed
#	1 - allowed
#
# Mandatory: no
# Default:
EnableRemoteCommands=1

### Option: LogRemoteCommands
#	Enable logging of executed shell commands as warnings.
#	0 - disabled
#	1 - enabled
#
# Mandatory: no
# Default:
# LogRemoteCommands=0

##### Passive checks related

### Option: Server
#	List of comma delimited IP addresses, optionally in CIDR notation, or hostnames of Zabbix servers and Zabbix proxies.
#	Incoming connections will be accepted only from the hosts listed here.
#	If IPv6 support is enabled then '127.0.0.1', '::127.0.0.1', '::ffff:127.0.0.1' are treated equally and '::/0' will allow any IPv4 or IPv6 address.
#	'0.0.0.0/0' can be used to allow any IPv4 address.
#	Example: Server=127.0.0.1,192.168.1.0/24,::1,2001:db8::/32,zabbix.domain
#
# Mandatory: no
# Default:
# Server=

Server=$ipProxy

### Option: ListenPort
#	Agent will listen on this port for connections from the server.
#
# Mandatory: no
# Range: 1024-32767
# Default:
# ListenPort=10050

### Option: ListenIP
#	List of comma delimited IP addresses that the agent should listen on.
#	First IP address is sent to Zabbix server if connecting to it to retrieve list of active checks.
#
# Mandatory: no
# Default:
# ListenIP=0.0.0.0

### Option: StartAgents
#	Number of pre-forked instances of zabbix_agentd that process passive checks.
#	If set to 0, disables passive checks and the agent will not listen on any TCP port.
#
# Mandatory: no
# Range: 0-100
# Default:
# StartAgents=3

##### Active checks related

### Option: ServerActive
#	List of comma delimited IP:port (or hostname:port) pairs of Zabbix servers and Zabbix proxies for active checks.
#	If port is not specified, default port is used.
#	IPv6 addresses must be enclosed in square brackets if port for that host is specified.
#	If port is not specified, square brackets for IPv6 addresses are optional.
#	If this parameter is not specified, active checks are disabled.
#	Example: ServerActive=127.0.0.1:20051,zabbix.domain,[::1]:30051,::1,[12fc::1]
#
# Mandatory: no
# Default:
# ServerActive=

ServerActive=$ipProxy

### Option: Hostname
#	Unique, case sensitive hostname.
#	Required for active checks and must match hostname as configured on the server.
#	Value is acquired from HostnameItem if undefined.
#
# Mandatory: no
# Default:
# Hostname=

Hostname=$nomeItop_$nomeItop

### Option: HostnameItem
#	Item used for generating Hostname if it is undefined. Ignored if Hostname is defined.
#	Does not support UserParameters or aliases.
#
# Mandatory: no
# Default:
# HostnameItem=system.hostname

### Option: HostMetadata
#	Optional parameter that defines host metadata.
#	Host metadata is used at host auto-registration process.
#	An agent will issue an error and not start if the value is over limit of 255 characters.
#	If not defined, value will be acquired from HostMetadataItem.
#
# Mandatory: no
# Range: 0-255 characters
# Default:
# HostMetadata=

### Option: HostMetadataItem
#	Optional parameter that defines an item used for getting host metadata.
#	Host metadata is used at host auto-registration process.
#	During an auto-registration request an agent will log a warning message if
#	the value returned by specified item is over limit of 255 characters.
#	This option is only used when HostMetadata is not defined.
#
# Mandatory: no
# Default:
# HostMetadataItem=

### Option: RefreshActiveChecks
#	How often list of active checks is refreshed, in seconds.
#
# Mandatory: no
# Range: 60-3600
# Default:
# RefreshActiveChecks=120

### Option: BufferSend
#	Do not keep data longer than N seconds in buffer.
#
# Mandatory: no
# Range: 1-3600
# Default:
# BufferSend=5

### Option: BufferSize
#	Maximum number of values in a memory buffer. The agent will send
#	all collected data to Zabbix Server or Proxy if the buffer is full.
#
# Mandatory: no
# Range: 2-65535
# Default:
# BufferSize=100

### Option: MaxLinesPerSecond
#	Maximum number of new lines the agent will send per second to Zabbix Server
#	or Proxy processing 'log' and 'logrt' active checks.
#	The provided value will be overridden by the parameter 'maxlines',
#	provided in 'log' or 'logrt' item keys.
#
# Mandatory: no
# Range: 1-1000
# Default:
# MaxLinesPerSecond=20

############ ADVANCED PARAMETERS #################

### Option: Alias
#	Sets an alias for an item key. It can be used to substitute long and complex item key with a smaller and simpler one.
#	Multiple Alias parameters may be present. Multiple parameters with the same Alias key are not allowed.
#	Different Alias keys may reference the same item key.
#	For example, to retrieve the ID of user 'zabbix':
#	Alias=zabbix.userid:vfs.file.regexp[/etc/passwd,^zabbix:.:([0-9]+),,,,\1]
#	Now shorthand key zabbix.userid may be used to retrieve data.
#	Aliases can be used in HostMetadataItem but not in HostnameItem parameters.
#
# Mandatory: no
# Range:
# Default:

### Option: Timeout
#	Spend no more than Timeout seconds on processing
#
# Mandatory: no
# Range: 1-30
# Default:
Timeout=30

### Option: AllowRoot
#	Allow the agent to run as 'root'. If disabled and the agent is started by 'root', the agent
#	will try to switch to the user specified by the User configuration option instead.
#	Has no effect if started under a regular user.
#	0 - do not allow
#	1 - allow
#
# Mandatory: no
# Default:
# AllowRoot=0

### Option: User
#	Drop privileges to a specific, existing user on the system.
#	Only has effect if run as 'root' and AllowRoot is disabled.
#
# Mandatory: no
# Default:
# User=zabbix

### Option: Include
#	You may include individual files or all files in a directory in the configuration file.
#	Installing Zabbix will create include directory in /usr/local/etc, unless modified during the compile time.
#
# Mandatory: no
# Default:
# Include=

Include=/etc/zabbix/zabbix_agentd.d/*.conf

# Include=/usr/local/etc/zabbix_agentd.userparams.conf
# Include=/usr/local/etc/zabbix_agentd.conf.d/
# Include=/usr/local/etc/zabbix_agentd.conf.d/*.conf

####### USER-DEFINED MONITORED PARAMETERS #######

### Option: UnsafeUserParameters
#	Allow all characters to be passed in arguments to user-defined parameters.
#	The following characters are not allowed:
#
# Mandatory: no
# Range: 0-1
# Default:
# UnsafeUserParameters=0

### Option: UserParameter
#	User-defined parameter to monitor. There can be several user-defined parameters.
#	Format: UserParameter=<key>,<shell command>
#	See 'zabbix_agentd' directory for examples.
#
# Mandatory: no
# Default:
# UserParameter=

####### LOADABLE MODULES #######

### Option: LoadModulePath
#	Full path to location of agent modules.
#	Default depends on compilation options.
#
# Mandatory: no
# Default:
# LoadModulePath=${libdir}/modules

### Option: LoadModule
#	Module to load at agent startup. Modules are used to extend functionality of the agent.
#	Format: LoadModule=<module.so>
#	The modules must be located in directory specified by LoadModulePath.
#	It is allowed to include multiple LoadModule parameters.
#
# Mandatory: no
# Default:
# LoadModule=

####### TLS-RELATED PARAMETERS #######

### Option: TLSConnect
#	How the agent should connect to server or proxy. Used for active checks.
#	Only one value can be specified:
#		unencrypted - connect without encryption
#		psk         - connect using TLS and a pre-shared key
#		cert        - connect using TLS and a certificate
#
# Mandatory: yes, if TLS certificate or PSK parameters are defined (even for 'unencrypted' connection)
# Default:
# TLSConnect=unencrypted

### Option: TLSAccept
#	What incoming connections to accept.
#	Multiple values can be specified, separated by comma:
#		unencrypted - accept connections without encryption
#		psk         - accept connections secured with TLS and a pre-shared key
#		cert        - accept connections secured with TLS and a certificate
#
# Mandatory: yes, if TLS certificate or PSK parameters are defined (even for 'unencrypted' connection)
# Default:
# TLSAccept=unencrypted

### Option: TLSCAFile
#	Full pathname of a file containing the top-level CA(s) certificates for
#	peer certificate verification.
#
# Mandatory: no
# Default:
# TLSCAFile=

### Option: TLSCRLFile
#	Full pathname of a file containing revoked certificates.
#
# Mandatory: no
# Default:
# TLSCRLFile=

### Option: TLSServerCertIssuer
#      Allowed server certificate issuer.
#
# Mandatory: no
# Default:
# TLSServerCertIssuer=

### Option: TLSServerCertSubject
#      Allowed server certificate subject.
#
# Mandatory: no
# Default:
# TLSServerCertSubject=

### Option: TLSCertFile
#	Full pathname of a file containing the agent certificate or certificate chain.
#
# Mandatory: no
# Default:
# TLSCertFile=

### Option: TLSKeyFile
#	Full pathname of a file containing the agent private key.
#
# Mandatory: no
# Default:
# TLSKeyFile=

### Option: TLSPSKIdentity
#	Unique, case sensitive string used to identify the pre-shared key.
#
# Mandatory: no
# Default:
# TLSPSKIdentity=

### Option: TLSPSKFile
#	Full pathname of a file containing the pre-shared key.
#
# Mandatory: no
# Default:
# TLSPSKFile=

  " > /etc/zabbix/zabbix_agentd.conf

service zabbix-proxy restart
service zabbix-agent restart

sudo wget -P /tmp https://app.hit.com.vc/automacao/saltinstallv2.sh --no-check-certificate && sudo chmod +x /tmp/saltinstallv2.sh
sudo sh /tmp/saltinstallv2.sh

else
  echo "Versão não suportada pelo script: $distro"
  echo "Por gentileza, consulte a equipe do HIT"
fi
