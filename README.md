#ansible_test  

An experimental lb/app/web cluster built for scale and flexibility

Role server count can be configured within the Vagrantfile for multi-machine config

#### Installation:
* Clone the repo
* Enter the folder
* Type  `rake`

Manual installation of requirements can be done via Homebrew and the included Brewfile

#### Vagrant commands:
* start machines: `vagrant up --no-provision`
* stop machines: `vagrant halt`
* provision a specified server role (e.g. lb-01): `vagrant provision lb-01`  
Machines are defined in the top section of the Vagrantfile - *the base machine memory is 512, bump it up if you've got plenty to spare*

#### Notable config files:
* Vagrantfile
* playbooks/site.yml - vagrant ansible config file
* playbooks/alpha-inventory.yml - example aws ansible inventory - replace with ec2.py for dynamic inventory
* playbooks/cluster.yml - external ansible inventory - replace with ec2.py for dynamic inventory

#### Notable folders:
* playbooks/vars/ - ansible config files
* playbooks/roles/ - ansible roles
* shared/ - vagrant guest mount folder
* shared/assets/ - nginx static folder

Tested on OSX, Ubuntu may require some tweaking

#### URLS:
All urls depend on DNS remotely defined or supplied by [xip.io](xip.io) or a hosts entry  
Haproxy supplies an HA virtual ip (vip) courtesy of keepalived and defined in the haproxy vars file, so point hosts, DNS or xip to that ip  
Default vip: 10.10.10.10
* [http://app.10.10.10.10.xip.io/sample](http://app.10.10.10.10.xip.io/sample) - jetty war sample app
* [http://static.10.10.10.10.xip.io/favicon.ico](http://static.10.10.10.10.xip.io/favicon.ico) - nginx static sample file

#####TODO:
  * Correct rolling_update to follow full description below
  * Restore dynamic haproxy config assembly with static improvements
  * Investigate Travis for continuous testing
  * See *Future* below

- - -

### Tools and components:
* [Vagrant](http://vagrantup.com/) 1.6+
 * excellent local provisioning
* [Ansible](http://ansible.com/) 1.5+
 * highly flexible and simple config mgmt
 * simple redirection between varied environments
* [Haproxy](http://haproxy.org/) 1.5.1
 * known to be highly scalable and often deployed in HA
* [Nginx](http://nginx.org/) 1.4.6
 * known for excellent binary serving
* [Jetty](http://eclipse.org/jetty/) 6
 * known for simplicity and scalability
* [Virtualbox](http://virtualbox.org/) 4.3+ or [VMWare Fusion](http://www.vmware.com/products/fusion) 6.04
 * virtualization option

### Approach
Of the components above, I have prior experience with all but Jetty though I have some prior recent experience with Tomcat - Jetty is commonly seen to be simpler and more performant. I've been looking to test it and this was a good opportunity. I tried in all cases to avoid any hard-coding in favour of dynamic inventory and variables, to allow for future scalability, simplified maintenance.

#### Two server groups initially:
* training (1-6 servers)
* prod (6+ servers)
  
<img src="https://docs.google.com/drawings/d/1tBW-ADGkW613DCqbva56TA_kah-mICYJo3xi78-b_OM/pub?w=960&amp;h=600">

- - -

### Challenges and proposals:
* **Shared, scalable persistence for legacy datastore**
 * drbd/syncthing/btsync/s3Fuse
* **Vagrant/AWS/Jenkins context switch**
 * Variable machine count in dev
 * Ansible + multi-inventory options
 * Role separation
* **Proper security practice**
 * Common hardening and least-privilege
 * Standard tools like ufw, fail2ban, logwatch and clamav
 * Sensitive data located on secure host, within environment variables where possible
* **Reproducible configuration**
 * Ansible with common role architecture, dynamic roles and inventory
* **Scaling and dynamic inventory**
 * Consider Consul
 * ec2.py for ansible dynamic inventory
 * May need to change Ansible execution method to accelerated mode or local provisioning @ hundreds of hosts

### Principles:
* **Effective separation of concerns by role**
 * Least-privilege - port restrictions and specialized user privileges
 * DRY
 * Single purpose roles
* **Secure interaction**
 * Hardened machines
 * No password auth
 * Allow for CI-driven provisioning
* **Scalability**
 * Allow for app/web/lb scaling at varied rates
 * Allow for special-purpose machine configuration for each role
* **Dev and prod parity**
 * Consistent deployment, identical role separation
 * Deployment flexibility - multi or single-server provisioning
* **Zero downtime**
 * Rolling updates
 * Redundant and HA architecture
 * Geographic distribution
* **Visibility and integration**
 * Event notification
 * ChatOps integration
 * Metric and log aggregation
* **Agility**
 * Configuration, app, assets and environment all individually deployable
 * Ansible configured to run with restricted tags, specified roles or only tests if desired

### Future: 
* Perfect forward secrecy [here](https://gist.github.com/rnewson/8384304)
* Replace Prevayler with RDS or noSQL
* Elastic load balancing/route53 - secondary dns
* Elastic IP remap - EC2 API Tools command ec2-associate-address
* Resource-based deployment:
 * OpenShift Origin Cluster
 * Mesos + Consul + Docker
 * CoreOS + Fleetctl + etc.d + Docker

#### Nice to have:
* P2P for legacy datastore persistence
* New Relic + alerts for APM
* Statsd for metric aggregation
* Logstash/Logsene for log aggregation

#### Shared persistence option for legacy datastorage:
2 or 3-phase commit combined with https://github.com/s3fs-fuse/s3fs-fuse is sufficient for shared persistence and consistency given the nature of the application (write light, read heavy) 
 * consider 5GB max for a single file

###Scaling:
* Packer to bake Ansible-provisioned AMI or Ansible and snapshot to enable autoscaling
* Considered boot with fetch script for war file (cloud-init?) though that would require connection back to CI which is a security risk
 * Jenkins will push to all servers

- - -

### Architecture:
* LB tier (haproxy) to abstract web/app servers from DNS
* LB tier is configured for HA via a heartbeat and floating public IP
* LB directs to Nginx for static.domain.com (webserver role)
* LB directs to Jetty for app.domain.com (appserver role)
* Jetty servers share data via btsync, syncthing, drbd or another
* On Vagrant, asset and artifact folders should be mounted from the host
* Single subnet haproxy to allow keepalive
* Route53 or ELB can be added in front to allow geo-distributed haproxy
 * Web and App servers can be geo-distributed for fault tolerance

### Rolling update method:
* Triggered by CI creation of new artifact (could be rollback)
* CI hosts assets and artifact
* deploy user is created to manage interaction with the server without root or vagrant

##### CI calls Ansible `rolling_update` playbook that runs within each web/app role serially:  
 1. Notify chat/new relic of deploy
 1. Chooses a web server and app server from the main pool
 1. Notifies the LB to move each to the maint-* frontend/backend
 1. Gracefully reloads LB
 1. Swings 'last' symlink for assets and artifact on chosen servers from release-2 to previous release
 1. Pushes assets.zip and artifact.war to chosen servers
 1. Extracts the asset zip, jetty extracts the warfile
 1. Swings 'current' symlink for assets and artifact on chosen servers from previous to current release
 1. Run curl to servers to ensure deployment success
 1. Notifies the LB to move each back into the main frontend/backend
 1. Runs a cleanup on releases older than release-2
 1. Progresses to next server in the pool
 1. Notify chat/new relic/sns of success

### On failure, trigger rollback:
 1. Restore asset and artifact symlinks
 1. Notifies the LB to move each back into the main frontend/backend
 1. Sends failure notification to chat/new relic/pagerduty/sns etc

### Haproxy recycle on changes:
 1. trigger iptables SYN drop
 1. wait for completion (port not listening)
 1. keepalive triggers live haproxy to take over shared IP
 1. restart haproxy
 1. open iptables

