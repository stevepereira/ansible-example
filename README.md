ansible_test
============

An experimental lb/app/web cluster built for scale and flexibility

Role server count can be configured within the Vagrantfile for multi-machine config

Contents:
* haproxy
* nginx
* jetty
* rolling deploy mechanism
* common best practice tweaks and customizations
* serverspec tests

Installation:
* Clone the repo
* Enter the folder
* Type  `rake`

Manual installation of requirements can be done via Homebrew and the included Brewfile

Tested on OSX, Ubuntu may require some tweaking

###TODO:
  * provision assets from local mount folder
  * multiple server provisioning
  * haproxy config - currently broken
  * haproxy VIP and keepalive
  * scalable servercount
  * flesh out documentation

