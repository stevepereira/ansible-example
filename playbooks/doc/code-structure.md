# Code structure

## Ansible playbooks

The _ansible_ directory contains [Ansible playbooks](http://docs.ansible.com/playbooks.html) that describe series of tasks that Ansible should run to install a reproducible copy of the service. Tasks are split into roles which can all be installed on one machine (single-machine.yml), or split into a cluster of machines (cluster.yml).

## Vagrantfile

The _vagrant_ directory includes configuration needed to setup a virtual machine and customize Ansible in order to create a local copy of the service for developers. The most important file here is the [Vagrantfile](https://docs.vagrantup.com/v2/vagrantfile/).
