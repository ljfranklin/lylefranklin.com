# Notes from Essential System Administration

Author: Æleen Frisch

Link: http://shop.oreilly.com/product/9780596003432.do

## Preface:

- macOS descended from the BSD line of UNIX while Linux came from the GNU line. Linux inherited some characteristic from BSD and some from System V.

## Chapter 1 - Intro:

- `su` inherits the environment from your current user, `su -` creates an environment as if the user had logged in directly
- Edit `/etc/sudoers` to modify who can use `sudo`
  - User can execute any command: `root ALL=(ALL:ALL) ALL`
  - Group can execute any command: `%admins ALL=(ALL:ALL) ALL`
- Display a welcome banner by modifying `/etc/motd`

## Chapter 2 - The UNIX Way:

- Files have a "user owner" and a "group owner" which are independent
- Change permissions via `chown` (change owner), `chgrp` (change group), and `chmod` (change file mode)
- You don't need write access to a file to delete it, you need write access to the parent directory
- umask sets the default file mode for newly created files
  - To set default mode to 755, run umask 022 (777 - DESIRED_MODE)
- inodes contain:
  - Owning user and group IDs
  - File mode
  - Access and modification times
  - Size of file
  - Number of hard links
  - Physical disk locations
- In UNIX everything is a file, even directories and devices
- A socket is a type of file used for inter-process communication, tied to a local system port
- Controlling processes:
  - `cmd &` (run process in background)
  - `^Z` (stop foreground process)
  - `jobs` (list background jobs)
  - `%N` (references a background job from jobs output)
  - `fg` (bring background process to foreground)
  - `bg` (Restart stopped background process)
- Daemons are background processes that run in the background, often from boot
  - E.g. `sylog` and `cron`
- Forking means an existing process creating an exact copy of itself (a child process) with a different PID
- `exec` will replace the current process with a child process, keeping parent's stdin/out and environment
- The `init` process has PID 1 and forks to create all other processes
- `/bin` is for executables needed to boot OS, `/usr/bin` is for distro managed executables, `/usr/local/bin` is for manually installed executables
- `mount /dev/DISK_ID /mnt/backups` to mount a given block device at the specified path
- The `/var` directory holds files that change over time, e.g. `/var/log`

## Chapter 3 - Essential Administration Tools and Techniques

- Print first column of output: `awk '{print $1}'`
- Avoid listing the `grep` process itself by enclosing the first character in brackets: `ps -ef | grep "[q]uake"`
- Find files by name: `find . -name '*.txt'`
- Find files modified less than 2 days ago: `find . -atime -2`
- Delete each found file: `find . -name foo -exec rm -f {} \;`, must end with escaped semi-colon
  - Change `exec` to `ok` to be prompted before each command
  - The `{}` characters are the placeholder for the filepath
- Find files larger than 500MB: `find . -size +500M -exec ls -l {} \;`
  - Be careful with rounding as `-size -1M` will only match empty files, not all files less than 1MB
- To kill each process in a pipe: `ps -ef | grep "[q]uake" | awk '{print $2}' | xargs kill`
  - To pass a single item at a time: `xargs -n1 CMD`
  - To use a placeholder: `xargs -i CMD -f {} -n`
  - Use `xargs -t -p` to be prompted before executing
- To "sandbox" an application and change its root dir: `chroot /jail CMD`
  - If CMD looks for `/var/log` it will actually be looking at `/jail/var/log`
- Print process tree: `ps auxf`
- Cron format: `<Minute> <Hour> <Day_of_the_Month> <Month_of_the_Year> <Day_of_the_Week> CMD`
  - Every hour: `0 * * * * echo foo`
  - Every day @ 2 AM UTC: `0 2 * * * echo foo`
- Cron config files:
  - `/etc/crontab` kicks everything off, shouldn't need edited directly
  - `/etc/cron.d/YOUR_CRON_FILE` can be used to specify arbitrary cron entries
  - `/etc/cron.{hourly,daily,weekly,monthly}/YOUR_SCRIPT` can run scripts directly without specify the cron format
- `rsyslog` pulls its config from `/etc/rsyslog.conf` and `/etc/rsyslog.d/*.conf`
  - Important log entries are present in `/var/log/auth.log` and `/var/log/syslog` to name a couple
  - Use logger to send messages to rsyslog: `logger -p auth.alert -t DOT_FILE_CHK "$user's $file is world-writeable"`
    - This would generate: `Feb 17 17:05:05 DOT_FILE_CHK: chavez's .cshrc is world-writable` in auth.log
- Boot/hardware errors can be view with the `dmesg` command
- A HUP signal can be used to tell syslog to release an active log during log rotation
- recalcitrant - having an obstinately uncooperative attitude toward authority or discipline.

## Chapter 4 - Startup and Shutdown

- The BIOS starts the Master Boot Program located in the first 512 bytes of the system disk, which then loads the kernel.
  - Not sure if this is still true on modern systems
- The kernel is the part of the system the remaining running the entire time the system is up
  - The kernel loads drivers and performs other necessary setup, then starts the init program
- init will verify the integrity of the filesystem, mount local disks, initialize paging areas, perform filesystem cleanup, start daemons, and enable user logins
- Linux boot logs can be viewed via dmesg
  - To view with color: `dmesg --color=always | less -R`
- fsck can be used to verify the integrity of the filesystem, although it does not verify the contents of individual files
  - Must be run on unmounted filesystem
- Mount a filesystem as read-write with `mount --rw /dev/sda2 /mnt/data`
- View available disk devices with `sudo fdisk -l`
- `swapon` and `swapoff` can be used to toggle swapping to available swap devices
  - `swapon --summary` will list current swap usage
- `free` will display memory usage, for more stats use `top` or `htop`
- `passwd` is used to change user passwords
- run level defines various system states that can be used to tweak when services start
  - From SystemV systems
  - Level 0: halted, safe to turn off computer
  - Level 2: most non-networked resources are available
  - Level 3: Network becomes available
  - Level 4,7,8,9: Administrator defined
  - Level 5: Same as 3 but with a graphical login prompt running
  - Level 6: System is rebooting / shutting down
- Use `telinit` to change the run level
- Linux shutdown now: `shutdown -h now`, reboot now: `shutdown -r now`, shutdown in 15 minutes: `shutdown -h +15`
- Run `sync` to flush cached writes to disk
- `fdisk` can be used to repair / recreate partitions

## Chapter 5 - TCP/IP Networking:

- A gateway is a machine that belongs to two networks (two NICs?) and passes data from one to the other.
- A MAC (Media Access Control) Address is a globally unique ID that is given to a Network Interface Card (NIC)
  - e.g.`00:00:f8:23:31:a1`
- A loopback interface allows a machine to send packets to itself
- Early ethernet setups used "Carrier Sense Multiple Access/Collision Detection" to retry if another device was already using the medium. This was due to every ethernet device being directly connected to other devices on the system. Modern ethernet systems connect each machine to a switch that avoids these collisions. Furthermore, newer protocols introduced full-duplex transmission so that switches and machines can send and receive at the same time, avoiding collisions entirely.
- The OSI Model is a conceptual model of describing the layers of telcom communication systems.
  - Application Layer 7: describes how user programs interface with the network
  - Presentation Layer 6: Specifies data representation to applications
  - Sessions Layer 5: Create, manage, destroys network connections
  - Transport Layer 4: Handles error control and sequence checking
  - Network Layer 3: Data addressing, routing, control flow
  - Data Link Layer 2: Defines access methods for the physical medium via network device drivers
  - Physical Layer 1: Specifies the physical medium's characteristics
- The TCP/IP Model is a similar, slightly simplified model:
  - Application Layer: Duties handled by user applications and network daemons. Encompasses the App. Layer, Presentation Layer, and some of the Session layer functions of the OSI Model.
  - Transport Layer: Handles session initiation, error and sequence checking. TCP and UDP protocols.
  - Internet Layer: Data addressing, routing, packet fragmentation and reassembly. IP and ICMP protocols.
  - Network access Layer: Handles interfacing with the physical medium. Ethernet protocol.
- Each layer adds a header to the data it receives from the layer above, encapsulating that data before passing down to the next layer. When the data is received on the other end, each layer removes its corresponding header to reveal the original message.
- Fragmentation is the process of splitting network data into smaller parts that can be transmitted separately.
  - Certain network hardware have a Max Transmission Unit (MTU), which is the largest data unit that can be transmitted across that network. This can cause performance issues if machines send larger units than the network can handle.
  - A typical ethernet MTU setting is 1500 bytes
- ARP (Address Resolution Protocol) determines how to determine a MAC address for an IP address
  - Sometimes the ARP cache must be cleared if a new machine comes up under a previously used IP address
  - There's also some way to broadcast that the MAC address has changed
- IP (Internet Protocol) manages lower-level transmission, routing, fragmentation/reassembly
- TCP (Transmission Control Protocol) ensures a reliable connection, handling flow control and error correction
- UDP (User Datagram Protocol) sends messages, or datagrams, without a connection or redelivery mechanisms.
  - Useful in time-sensitive systems that are tolerant to dropped messages, e.g. video streaming, online video games
- The /etc/services file contains a list of standard mappings of ports to services
- A service is the combination of a protocol and a port
- A socket is the combination of a host and a port (source IP address, source port, destination IP address, destination port)
  - To enable multiple concurrent sessions (e.g. multiple SSH connections from a single client) the remote host will dynamically assign a random port as the destination port for that client, ensuring a unique socket per connection
- Helpful network commands: `hostname`, `ifconfig`, `ping`, `arp`, `netstat`, `route`, `traceroute`, `nslookup`
- TCP connection flags (multiple flags can be sent in same response):
  - SYN: attempt to create a new network connection
  - ACK: acknowledge that a packet was received. Used in conjunction with `th_seq` and `th_ack` fields.
  - PUSH: indicates user data is included in packet
  - FIN: indicates connection will be terminated
- A subnet mask describes how the network and host parts of an IP range by using binary 1 to denote the network part and 0 for the host part
  - E.g. `255.255.0.0` means the first two octets are the network part and the second two are the host part
- CIDR (Classless Inter-Domain Routing) notation describes the subnet mask and the range of routable IPs by using IP/MASK
  - e.g. `192.168.0.0/16` says the left-most 16 bits are fixed (`192.168`) and the remaining bits are the host part
- To broadcast a message to all hosts in the network, use the network prefix followed by 255 octets.
  - E.g. in a `192.168.1.0/24` network, broadcast is `192.168.1.255`
- The part of the address that is fixed in the CIDR is the network part, while the remaining values are the host part
- `10.0.0.0/8` and `192.168.0.0/16` are reserved for private networks
- NAT (Network Address Translation) can map private internal addresses to a shared external IP address.
- IPv6 addresses are 128 bits long, 8 colon separated 16 bit values written in hexidecimal
  - e.g. `2001:0db8:85a3:0000:0000:8a2e:0370:7334`
  - The loopback device is `::1` and the broadcast is `FF02::1`
- A switch can be used to connect machines on the same network, routing ethernet frames to the target MAC address (OSI Data Level 2)
- A router can be used to one network to another network, routing packets based on IP addresses (OSI Network Level 3). Routers can also perform NATing.
- Manually configure loopback interface ifconfig lo localhost up
- Manually configure ethernet interface: `ifconfig eth0 inet 192.168.1.9 netmask 255.255.255.0`
- The `/etc/hosts` file contains a mapping of hostnames to IP addresses
- You can set hostnames for the entire network by changing the hostname field in the DHCP setting for the given machine's MAC address
- You can set network interfaces via `/etc/network/interfaces`
  - DHCP example: `iface eth0 inet dhcp`
  - Static IP example:
    ```
    auto eth0
    iface eth0 inet static
      address 192.0.2.7
      netmask 255.255.255.0
      gateway 192.0.2.254
    ```
- DHCP (Dynamic Host Configuration Protocol) is used dynamically assign IP addresses to machines on the network
  - The client requests an address by broadcasting a "DHCP Discover" message to UDP port 67
  - The DHCP server replies with a "DHCP Offer" message to UDP port 68. This message contains the new IP, subnet mask, lease duration, and DHCP server IP
  - The client responses by broadcasting a "DHCP Request" containing the offered IP address
    - The allows multiple DHCP servers to release the pending reservation
  - The DHCP server that sent the IP to the client will send a "DHCP Acknowledge" to the client
  -  When the lease has 50% time remaining, the client will attempt to renew the address via another "DHCP Request" message
    - Typically leases are a few hours
  - DHCP can also be used to assign: hostnames, DNS servers, NTP servers, and default gateways.
    - The requested options can be set via `/etc/dhcp/dhclient.conf`
- Hostname lookup will first check `/etc/hosts`, then query the DNS server
  - The order of this lookup is specified in `/etc/nsswitch.conf`
  - Example `/etc/hosts` entry: `192.168.0.7 my_hostname`
- DNS config is stored in `/etc/resolv.conf`
  - Specify the DNS server IP: `nameserver 192.168.9.44`
  - Specify search domains: `search sf.pivotallabs.com`
    - Search domains allow you to enter a non-FQDN that belongs to that domain, e.g. `nslookup workstation` might return `workstation.sf.pivotallabs.com`
    - By default this search lookup is only performed if your domain name does not contain a `.`
- You can statically define how to route packets to a give IP range via the `route` command
  - Example from bosh-lite: `sudo route add -net 10.244.0.0/16 gw 192.168.50.4`
  - List current routes by running just route
- `arp -a` displays the IP to MAC address translation table
  - The can be used to debug whether multiple machines have grabbed the same IP
  - Had an issue on AWS where our home-rolled proxy would fail to route to a VM that was recreated and came back under the same IP IFF the VM was in the same subnet as the proxy. Running `arp -d VM_IP` fixed the issue, but better is to have the VM send a gratuitous ARP message when is comes back up.

## Chapter 6 - Managing Users and Groups

- Important files for user management:
  - `/etc/passwd` - Lists user accounts, home dir, shell
    - Example line: `username:x:UID:GID:user information:home-directory:login-shell`
  - `/etc/shadow` - Lists encoded user passwords
    - Unlike `/etc/passwd`, this file is only readable by root
    - Example: `username:encoded password:changed:minlife:maxlife:warn:inactive:expires:unused`
  - `/etc/group` - Lists groups and membership
    - Example: `name:*:GID:additional-users`
  - `/etc/gshadow` - Lists group admins and passwords (Linux only)
    - Example: `group-name:encoded password:group-admins:additional-users`
- `newgrp` allows a user to change their primary group, but they must already be a member of that group
- root - The superuser account with a UID of 0
- Groups `root`, `system`, and `wheel` (OS dependent) are groups with a GID of 0 that own many system files
- Groups `users` or `staff` are typically the default group for new users
- `rbash` is a restricted shell that only allows the user to execute commands from the default working directory
  - commands such as `cd` and output directs are disabled
- Change or assign password with `passwd USERNAME`
- The files `.login`, `.bash_login`, `.profile` and `.bash_profile` in the home dir and loaded at login. The file `.bashrc` is loaded everytime a new shell is spawned
- `/etc/profile` and `/etc/profile.d/*` are loaded for all users in the system
- The file `/etc/security/limits.conf` and `/etc/security/limits.d/*` can apply resource limits to users like cores and open files
- Lock an account with `passwd -l USERNAME`
- Example command to add a new user: `useradd -g chem -G bio,phys -s /bin/tcsh -c "Rachel Chavez" -m chavez`, can be modified or deleted with `usermod` and `userdel`
- PAM (Pluggable Authentication Modules)
  - general authentication interface which allows programs to be developed independently of user-auth schemes on system
  - PAM config files list a set of checks a user must pass in order to use a command, e.g. allow if root, else check group membership and ask for password
- LDAP (Lightweight Directory Access Protocol)
  - Common use is storing usernames and passwords in a centralized server
  - Example entry:
  ```
  dn: cn=Jerry Carter, ou=MyList, dc=ahania, dc=com
  objectClass: person
  cn: Jerry Carter
  sn: Carter
  description: Samba and LDAP expert
  telephoneNumber: 22
  ```
    - `dn` is the distinguished or fully-qualified name
    - `dc` is domain component
    - `cn` is common name
    - `objectClass` is type of record as defined in the LDAP schema
    - `ou` is organization unit
  - Can modify schema to add fields or mark them as required or optional
  - Can configure PAM to use LDAP for auth: `auth sufficient /lib/security/pam_ldap.so`

## Chapter 7 - Security

- Think about the worst case "impossible" scenario, e.g. what if all the computers in the office were stolen?
- Security is only as good as its most vulnerable part
- Lines of UNIX defense:
  - Physical security: can't get into the building where the computers live
  - Network/firewall rules: can't remotely get into computer
  - Passwords: can't login as a user you don't control
  - Encryption: can't read files on disk unless you have the key
  - Backups: repair some of the harm done
- Two factor auth: something you know (password) + something you have (phone/yubikey)
- Kerberos
  - secure authentication over a public network
  - Kerberos is used for authentication, while LDAP can be used for authorization
  - Limitation: clocks must be in sync across network as the current time is used in the encryption
- Search path vulnerability: All directories in root's PATH should only be writable by root
- setuid and setgid can be used to allow a user to run a binary with the effective permissions of the file or group owner
  - `chmod +x u+s FILES`
  - One program that uses this flag is `/bin/passwd`
  - Security vulnerability if not used carefully
- Linux supports ACLs if the UNIX permissions are not flexible enough
  - Can add permissions to a file for any number of users and groups
- `gpg` can be used to encrypt/decrypt files using public/private keys
- SSH server config lives at `/etc/ssh/sshd_config`
- The files `/etc/hosts.allow` and `/etc/hosts.deny` can be used to give access to network services to only select clients
  - Can hostnames be spoofed?
- `nmap` can be used to scan the open ports on a system
  - Useful for checking for security vulnerabilities but don't run on systems you don't own!
- IP spoofing: changing the source IP header in the IP packet to pretend the packet is coming from a trusted source
- A network firewall can help prevent attacks by checking for some spoofed IPs, dropping traffic to untrusted ports, straddles the external and internal networks to proxy connections to internal components
- Chapter includes a checklist for common security setup actions under the Hardening section
- View history under `~/.bash_history`
- The `last` command shows the last time each user logged in

## Chapter 8 - Managing Network Services:

- DNS: Domain Name System
  - the spec that maps hostnames to IP addresses
  - BIND is a popular DNS implementation
  - Domain names form a hierarchical tree with top-level domains (TLD) like '.com' at the root, followed by nested subdomains like 'google', and the leaf is the actual hostname like 'mail'. Put together you have 'mail.google.com'
  - DNS zone: the collection of hosts within a domain, excluding any subdomains. Subdomains can be nested as forwarded zones.
    - For each forward zone (hostname -> IP) there is a reverse zone (IP -> hostname) ending in `*.arpa`
  - In a recursive DNS queries, if the first nameserver doesn't know the answer it will forward the request to a server that does
  - Authoritative answers are given directly by the designated holders of a particular domain, non-authoritative answers are cached responses from other servers
  - Types of nameservers:
    - Authoritative: Master nameservers hold the official copy of a DNS record, Slave nameservers grab DNS records from their zone's master
    - Caching-only servers: hold no official records but cache DNS results from other servers for a time
    - Forwarders: servers designated for queries that are outside the current zone, relieves loads on the authoritative servers and builds up a strong cache on the forwarders
  - BIND requires a "hint" file which lists the root nameservers that should handle requests outside the current zone
  - Time to Live (TTL) is the amount of time a DNS record is able to be cached before needing to re-query the server
  - Type of DNS records:
    - SOA (start of authority) lists info about the zone like the master name server address, the master's serial version, and some timeout settings
      - remember to update the serial number each time the master config changes so the slave servers will fetch the new info
    - NS (name server) lists the authoritative nameservers (master and slaves) for a zone
      - Use the server's canonical DNS entry, not a CNAME alias
    - A (address) maps a hostname to an IPv4 address
    - AAAA (address) maps a hostname to an IPv6 address
    - CNAME (alias) creates a hostname that is an alias for another hostname
    - MX (mail server)
    - SRV (server selection) advertises a particular service like FTP
    - PTR (pointer) maps an IP to a hostname for reverse DNS queries. Used for troubleshooting and required by some applications like mail servers
  - Use of forwarders can improve cache performance. Alternatively, keeping the total number of DNS servers per site small can build a strong cache.
  - DNS servers can receive dynamic updates from DHCP servers as new IPs are handed out
  - DNS records that are updated dynamically should be placed in a separate zone to avoid clobbering static records
  - `update-policy` rules grant more fine-grained access to which servers can update which zones and requires crypto signing on requests
  - BIND9 supports TSIG for symmetric crypto, DNSSEC for asymmetric
  - DNS views can be used to return a different result based on the IP of the client, e.g. internal vs external traffic
  - DNS maintenance:
    - Update root hints a couple times a year
    - Add more servers if load or topology changes
    - Monitor reliability
- Routing concepts
  - static routing involves an admin manually adding fixed routes to each machine, dynamic routing autonomously selects the best route by maintaining a routing table
  - Routing daemons:
    - `routed` is the classic utility which is simple but widely available. Newer systems use BIRD.
  - Routing algorithm types:
    - distance-vector: attempts to find the fewest number of hops to a destination, simpler implementation but slower to adapt to network changes
    - link-state: builds a map of the network topology to route traffic, more resource intensive but faster to adapt to network changes
    - Internal routing algorithms determine how to route packets within a local network
    - External routing algorithms determine how to route packets between networks
  - Routing Information Protocol (RIP)
    - Simple distance-vector protocol used in internal routing
    - Each router broadcasts its route table periodically, routers use the route tables from their neighbors to compute hop distance
    - Limited by short range (15 hops max) and slow convergence on network changes
  - Open Shortest Path First (OSPF)
    - Link state protocol used in internal routing
    - Builds a directed graph of the network from each router's perspective, periodically shares link-state database with neighbors
    - Allows network to be subdivided into "areas" with "border routers" connecting different areas. The "backbone" is a shared area that connects all other areas
- DHCP (Dynamic Host Configuration Protocol)
  - allows a machine to acquire a dynamic IP on the network
  - Each DHCP server is given a range of IPs to manage called `scopes`
  - A DNS relay can forward DNS requests from one subnet to another
  - Each machine broadcasts a DNS request when it joins the network, so each subnet should contain a DNS server or relay
  - On Ubuntu 16.04, DHCP lease info can be found at `/var/lib/NetworkManager/dhclient*.lease`
  - You can listen for DHCP traffic with `sudo tcpdump -i <network-interface> port 67 or port 68 -e -n` or `sudo dhcpdump -i <network-interface>`
    - DHCP servers listen on 67 and clients on 68
- NTP (Network Time Protocol)
  - Used to synchronize system time between servers
  - Ubuntu 16.04 uses the timesyncd client
  - NTP servers are hierarchical with authoritative "stratum 1" servers that receive time directly from a reference clock, "stratum 2" servers receive time from the 1st tier, and so on.
  - NTP clients are fault tolerant and prefer at least three sources of time to ensure a correct result
  - NTP supports authentication by allowing clients and servers to check for trusted certificates
- Network monitoring
  - `netstat` can be used to list active connections with the local host, `netstat -a` also shows what ports are being listened on.
  - `ping` can be used to test connectivity to a host. Ping can also take a packet size to test packet fragmentation for packets larger that the MTU, defaults 1500.
  - `traceroute` shows the path a packet took to its destination
    - It computes the route by sending a packet with a TTL of 1, checking the results, the sending one with TTL 2, and so on to build a path
    - A '*' indicates that the router or gateway refused the ICMP packet or failed to send a TTL expired error message
  - `tcpdump` shows the individual packets being sent or received by the local host
    - Show packet headers and content to a given host and port: `tcpdump host example.com and tcp port 80 -e -X`
    - `ngrep` similarly allows searching the contents of packets for a given regex
  - SNMP (Simple Network Management Protocol)
    - Common interface to enable data collection and parameter setting on network components like routers
    - A schema (which properties it exports) for a given device can be uploaded to a Management Information Base (MIB)
    - Devices support read-only and read-write modes. Some devices come with read-only SNMP turned on with a default password which should be changed before attaching to network
  - Nagios is an open source networking monitoring tool used to check for networking issues on routers, switches, and links. Web GUI.
  - Cacti is another web GUI networking monitoring tool with a focus on showing network performance

## Chapter 9 - Electronic Mail:

- Skipped for now

## Chapter 10 - Filesystems and Disks:

- Common filesystem types:
  - NFS: network attached storage
  - Ext3: default on LTS Linux systems
  - Ext4: default on newer Linux installations
  - XFS: supports advanced features like files as large as 8 EiB (Exbibyte)
  - NTFS: default Windows file system
  - tmpfs/ramfs: filesystem backed by RAM rather than a hard disk
- block: the basic unit of filesystem storage
  - Blocks are a fixed size, e.g. 4096 bytes
  - Check current block size with blockdev --getbsz `/dev/PARTITION`
  - Files are made up of one or more blocks, any extra space in the last block is wasted space. This means large block size may have better performance for large files but waste space if there are many small files
- Journaled Filesystems
  - Protects against filesystem damage by writing all metadata to a transaction log prior to writing the contents to disk
  - This transaction log allows integrity checks to complete quickly
- Mounting is the process of adding a filesystem to the system directory tree
  - Mount a given filesystem at the given path: `mount /dev/sda2 /home`
  - All files that already existed at the mount point on the root filesystem are hidden until the filesystem is unmounted
  - Mount a filesystem as read-only: `mount -r /dev/sda2 /secrets`
  - Unmount a filesystem: `umount /dev/sda2` or `unmount /home`
  - If the filesystem won't unmount because it is busy, see which process to using it: `fuser -u -m /dev/sda2`
  - The devices listed in `/etc/fstab` will be mounting automatically on boot
    - Example line: `<special-file> <mount-dir> <fs-type> <options> <dump-freq> <fsck-pass>`
      - dump-freq: indicates how often this fs should be backed up by the `dump` util
      - fsck-pass: indicates the order in which fsck will scan disks. Lower numbered filesystems, e.g. boot and root, get scanned first
- An `inode` records metadata about a file like permissions and access time as well as containing a pointer to the block of data in the filesytem which stores the file contents
  - The filename is not stored in the inode, it is stored in the directory (which is itself a file)
- Use `fsck` to check for filesystem issues and optionally repair them
  - Common issues: one block belonging to multiple inodes, blocks marked as free but are in use, inconsistencies in filesystem tables
  - fsck can locate non-empty inodes that are not listed in any directories and will place corresponding entries in the `lost+found` directory
  - fsck can only repair the structure on a corrupted file, it cannot repair corrupted file contents
  - Automatically perform non-destructive repairs with `fsck -p`
- Disk partitions
  - A single physical disk can be divided into one to many partitions, each of which looks to the OS like an independent device
  - Use `fdisk /dev/DEVICE` or `gparted` to create or modify partitions
- I may have had an old edition, but the section on physically plugging in hard drives is a bit dated now. Talks about IDE and SCSI devices, but doesn't include newer SATA interfaces or SSDs.
- Once you've created a partition, you need to create a filesystem on that partition
  - To make an ext4 filesystem: `mkfs.ext4 /dev/sdaX`
- A logical volume manager (LVM) can also be used to combine several separate physical disks into a single logical disk from the OS perspective
- RAID (redundant array of independent disks) has several modes to aggregate multiple physical disks into a single disk
  - RAID 0: Striping; splits a logical disk across multiple physical disks without redundancy to improve I/O performance
  - RAID 1: mirror all data onto one or more additional physical disks for data redundancy.
  - Higher levels of RAID perform a combination of striping and mirroring
  - RAID can be implemented either in software or down at the firmware level
- Skipped the sections of floppy disks and CD-ROMs 😃
- NFS (Network File System):
  - enables sharing a drive across a network from one UNIX system to another
  - looks like a locally mounted disk to the client
  - host sharing the disk must list the filesystem under `/etc/exports`
    - access can be restricted to given hostnames and user accounts
  - NFS drives can be mounted automatically at boot by adding an entry to `/etc/fstab` with type `nfs`
  - NFS can be mounted as `hard` or `soft`. In the event of a networking error, `soft` will retry a given number of times then return a filesystem error while `hard` will hang until the issue is resolved or the process is killed.
- Samba allows for sharing drives between Windows and Unix machines
  - Implementation of the Server Message Block (SMB) protocol which is the default windows sharing protocol
  - It supports a username map file that translates between UNIX users and Windows users
  - Sambda drives can be mounted automatically at boot by adding an entry to `/etc/fstab` with type `smbfs`

## Chapter 11 - Backup and Restore:

- Questions to ask when designing a backup system:
  - What files need to be backed up?
  - Where are these files?
  - Who will back up the files?
  - Where, when, and under what conditions should backups be performed?
  - How often do these files change?
  - How quickly does an important missing or damaged file need to be restored?
  - How long do we need to retain this data?
  - Where should the backup media be stored?
  - Where will the data be restored?
- Start with your ideal backup schedule then scale back if you hit limitations
- There are no guarantees when attempting to backup an open file, ideally backup idle systems
- A full backup includes every file in the system while an incremental backup only includes the files that have changed since the last backup
  - A incremental backup also requires the last full backup in order to restore
- Backups should be checked for integrity periodically
- Consider security when storing backups
  - Who has physical access to backup media?
  - Do I need to encrypt the backup?
- To make a permanent back for archiving, make two backup copies and attempt to restore at least once a year.
  - If a drive dies, make a copy from the remaining backup
- Magnetic tape was the primary backup media when the book was written, guessing this has changed since then
- Create a gzipped tar archive: `tar czf ./my-backup.tgz /home`
  - The above command saves absolute paths. For relative paths: `tar czf ./my-backup.tgz -C /home .`
- `cpio` was preferred for backing up to tape as it more gracefully handled issues in tape media
- Full filesystems backups can also be made with `dump`, `rsync`, or `dd`
- Tape backups can run into issues when restoring on a system other than the one that created the backup
- Amanda (Advanced Maryland Automated Network Disk Archiver) is a centralized network backup system

## Chapter 12 - Serial Lines and Devices:

- Serial lines are the legacy interface for connecting peripherals like printers and modems to computers
- The communicate standard for serial lines is called RS-232
- The special files for serial lines are `/dev/tty*`
- The `/dev/tty` file refers the each process' controlling terminal
  - `echo 'foo' > /dev/tty` will print to the current shell's STDOUT
- The `/dev/console` file is a pointer to the current display, usually `/dev/tty0`
- Terminal emulators can use `/dev/pts/N` files to simulate a serial device
- List the current TTY file with `tty`
- terminfo config files describe the capabilities of different terminals
  - The `$TERM` env variable says which terminal settings to use
  - The config files on Linux live in `/etc/terminfo/` and `/lib/terminfo/`
  - View or edit terminfo settings with `infocmp`
- The `tset` command will initialize terminal settings based on the value of `$TERM`
- The `stty` command is used to change how the terminal responds to certain key inputs
  - List current settings: `stty -a`
  - Send interrupt signal with Ctrl+k instead of Ctrl+c: `stty intr ^k`
  - Don't print typed characters to screen (e.g password entry): `stty -echo`
  - Stop all terminal input with `^S`, start it again with `^Q`
  - Send EOF: `^D`
  - Reset terminal to default settings: `stty sane`
- Baud rate: Bits per second rate that should be used when communicating with serial device
- RS232 a simpler, lower-level protocol that allows a single serial port to control a single device
- USB is a more complicated protocol that allows a single port to control many devices, e.g. USB hub
- The `/etc/inittab` contains some terminal initialization options
  - Example line: `1:2345:respawn:/sbin/getty 38400 tty1`
- Shows active processes in current terminal: `ps -t`
- List usb devices: `lsusb`

## Chapter 13 - Printers and the Spooling Subsystem:

- Skipping for now

## Chapter 14 - Automating Administrative Tasks:

- This chapter gives examples of semi-complex shell scripts to automate tasks like checking for accounts without passwords or monitoring disk usage
- The `comm` command can be used to diff two files, showing additions and subtractions
- Can use hidden files to configure cron jobs, e.g. creating `$HOME/.no_lucia` to disable the lucia cron job
- Good tips for writing scripts and programming in general:
  - Build the script up gradually
  - Test and debug the logic independently of the functionality if possible
  - Use the shell’s -v option
  - Perform testing and debugging on local copies of system files
  - Use small cases for initial tests
  - Don’t forget to test boundary conditions
  - Assume things will go wrong
  - Write for the general case
- Gives introductions to Perl, Expect, and C for writing automation scripts
- Custom man pages can be added under `/usr/share/man/man1` to document your custom tools
  - These pages are written with troff typesetting (or GNU groff)

## Chapter 15 - Managing System Resources:

- High-level options when you don't have enough of a resource: get more, use less, eliminate inefficiency and waste to make the most of what you have, or ration what you have
- Tuning Process:
  - Define the problem in as much detail as you can.
  - Determine what’s causing the problem.
  - Formulate explicit performance improvement goals
  - Design and implement modifications to the system and applications to achieve those goals
  - Monitor the system to determine how well the changes worked
  - Return to the first step and begin again
- `uptime`: prints how long the system has been running and average load over last minute, last 5 minutes, and last 15 minutes
- A load of 1.0 means a 1 core machine is busy 100% of the time with no processes waiting in the queue. A load of 2.0 on a 1 core machine means there is always one process running and one waiting in the queue. Load is per core, so a 2 core machine is 100% utilized with a load of 2.0.
- View running processes with `ps`
  - `ps aux` lists processes in decreasing CPU usage order
- `pstree` visualizes parent and child processes
- `top` (or `htop`) shows the current system status and the top processes by usage
- The `/proc` directory contains files listing information about the system and running processes
  - View CPU info with `cat /proc/cpuinfo`
  - View process info with files under `/proc/PID/`
- You can impose limits on processes (e.g. number of open files) with `ulimit`
  - Soft limits (`ulimit -a`) are imposed on new processes by default
  - Hard limits (`ulimit -Ha`) are system-wide defaults that only superuser can change
- Destroy a running process with `kill [-signal] PID`
  - `kill PID` sends the TERM signal to all the process to gracefully shutdown
  - `kill -9 PID` sends the KILL signal to immediately destroy the process without giving it time to cleanup
  - `killall PROCESS_NAME` will kill all processes with the given name
  - Zombie processes cannot be killed. These result when the kernel sends a message to the parent of the process-to-kill but the parent does not respond.
  - Processes waiting for an NFS resource will not respond to KILL, use QUIT or INT instead
  - Processes waiting for a device to finish I/O may not die on KILL
- STOP (Ctrl-z) and CONT (fg) can be used to suspend and resume processes
- Many systems use priority-based round-robin scheduling
  - Each process is assigned a priority number, lowest goes first when CPU is available
- Once a process is scheduled, it will run until one of the following happens:
  - it needs to wait for an I/O operation to complete
  - receives an interrupt from the kernel
  - process gives up control of the CPU
  - it exhausts the maximum execution time slice (or quantum) defined on that system (10 milliseconds
is a common value)
- Processes with the same priority go into a FIFO queue
- Each process has a requested priority or `nice number`
  - This number is used to compute actual priority along with other factors like how much CPU time the process has had recently
  - Any user can run a program with an increased nice number with `nice`, only the superuser can decrease a nice number
  - Change the nice number of a running process with `renice NICE PID`
- `vmstat`: Get a dump of system statistics like CPU activity
  - `vmstat SECONDS_BETWEEN_REPORTS NUMBER_OF_REPORTS`
  - first line of output is stats since boot, often can be ignored
  - `so` or swap out should be close to zero unless there is a memory shortage
- Technically `swapping` refers to writing an entire process from memory to disk while `paging` involves moving sections of a process' memory to disk. In practice full `swapping` is rarely used anymore and the terms are used interchangeably to refer to `paging`.
  - paging involves a big performance hit as moving data back and forth between disk and RAM is slow and CPU intensive
- If memory is full and a new process needs memory, the OS chooses an existing section of memory to `page out`
- `free`: determine amount of physical memory used and available
- Linux allows you to tweak some memory management params by editing files under `/proc/sys/vm/`. Be careful, make good decisions.
- systems use either a dedicated swap partition or swap file for swapping/paging.
- The "correct" size of the paging area will vary based on what type of work the machine will perform. In general swapping should be avoided by correctly allocating memory rather than optimized
- `swapon -s`: list current swap usage
- Create a new swap file on linux:
  ```
  dd if=/dev/zero of=/swap1 bs=1024 count=8192 # Create 8MB file.
  mkswap /swap1 8192 # Make file a swap device.
  sync; sync
  swapon /swap1
  ```
- `sar`: monitor disk i/o
  - `sar -d INTERVAL [COUNT]`
  - Output is `timestamp device transactions_per_second blocks_transfered_per_second`
- The section on optimizing Disk I/O hardware is unfortunately a little dated in the edition I read, e.g. doesn't mention SSDs
- `df -h`: Check remaining disk space by device
- `du -h`: Check how much space given directory is using
  - List directories sorted by size: `du -m / | sort -rn`
- Use `find` to locate junk files to free up space: `find / -name ".BAK.*" -o -name "*~" -print`
- Enforce per-user disk quotas by adding `usrquota` entries to `/etc/fstab`
- `netstat -s`: display summary of network performance issues like re-transmitted and dropped packets
- maximum segment size (MSS): largest TCP packet size that the OS will transmit
- Socket buffer size: the OS stores outgoing TCP messages in a buffer before sending. A full buffer will delay future messages.
  - Change max buffer size by editing `/proc/sys/net/ipv4/tcp_rmem`
- Improving DNS performance
  - list multiple DNS services in `/etc/resolv.conf` on all client machines
  - Using designated forwarders
  - Use separate servers for external and internal DNS queries
- `nfsstat` monitor NFS performance

## Chapter 16 - Configuring and Building Kernels:

- The kernel has many responsibilities including:
  - Process creation, termination and scheduling
  - Virtual memory management
  - Device I/O
  - Inter-process communication
  - Enforcing access control and other security mechanisms
- Building a custom kernel is almost never necessary, but can be used to add support for new devices or tweak non-configurable params for example.
- Linux kernel image lives at `/boot/vmlinuz-VERSION` and build dir at `/usr/src/linux-VERSION`
- Chapter gives detailed commands for building kernels on Linux, FreeBSD, and other systems
- grub (Grand Unified Bootloader): provides a menu at boot time to select your OS and provide boot options
  - Config lives at `/boot/grub/grub.cfg`
- Linux can also be built with dynamic modules to cut down the size of the kernel and avoid rebuilds

## Chapter 17 - Accounting:

- `/var/run/` holds system data for currently logged in user which is not needed across reboots
- `/var/log/` holds system logs such as when a user logged in or out
- `accton`: enables process accounting
  - this logs the actions of all users to a file
  - the `sa` command can be used to summarize the accounting file
- `ac`: list how long each user has spent logged in

## The Profession of System Administration:

- "system administrators are valuable technical professionals, and they should be treated as such"
- SAGE: System Administrators Guild
- LISA: Large Installation System Administration conference
- Administrator Virtues:
  - Flexibility
  - Ingenuity
  - Patience
  - Persistence
  - Adherence to Routine
  - Attention to Detail
  - Laziness
- "Don’t forget to have fun. Life is too short."

## Appendix:

- Gives a nice intro to writing scripts in `sh`. Covers control structures like `for` and `if`, reading input with `read`, and declaring variables.
