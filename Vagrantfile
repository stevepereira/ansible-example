# -*- mode: ruby -*-
# vi: set ft=ruby :

# Set box configuration options
box = 'puphpet/ubuntu1404-x64'
boxname = "dev"
boxipaddress = "10.10.10.10"
memory = 2048

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
# Find the current vagrant directory.
vagrant_dir = File.expand_path(File.dirname(__FILE__))

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Configure virtual machine options.
  config.vm.box = box
  config.vm.hostname = boxname
  config.vm.box_check_update = false

  config.vm.network :private_network, ip: boxipaddress

  # Allow caching to be used (see the vagrant-cachier plugin)
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.synced_folder_opts = { 
        type: :nfs,
        mount_options: ['rw', 'vers=3', 'tcp', 'nolock'] 
    }
    config.cache.scope = :box
    config.cache.auto_detect = true
  end

  # Manage vbguest update
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
    config.vbguest.no_remote = true
  end

  # Configure virtual machine setup.
  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--memory", "#{memory}"]
  end

  # SSH Set up.
  config.ssh.forward_agent = true

  # Provision vagrant box with Ansible.
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = vagrant_dir + "/playbooks/site.yml"
    ansible.inventory_path = "vagrant-ansible-inventory"
    ansible.host_key_checking = false
    ansible.limit = 'all'
    ansible.extra_vars = { clear_module_cache: true, ansible_ssh_user: 'vagrant' }
    ansible.raw_ssh_args = '-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o IdentitiesOnly=yes'
    ansible.verbose = ''
    ansible.skip_tags = "non-local"
    # ansible.tags = ‘nginx’
    # ansible.start_at_task = ‘’
    end
end
