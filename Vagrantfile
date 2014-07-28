# -*- mode: ruby -*-
# vi: set ft=ruby :

# Set box configuration options
box = 'puphpet/ubuntu1404-x64'
memory = 512
gui = false
cpus = 2

# default config uses a vip 10.10.10.10 that should be configured for all fqdns
boxes = [
  { :name => 'lb-01', :aliases => ['lb-01.example.dev'], :type => :loadbalancer, :ip => '10.10.10.11', :primary => true, :cpus => $cpus, :memory => $memory },
  { :name => 'web-01', :aliases => ['web-01.example.dev'], :type => :webserver, :ip => '10.10.10.12', :primary => false, :cpus => $cpus, :memory => $memory },
  { :name => 'app-01', :aliases => ['app-01.example.dev'], :type => :appserver, :ip => '10.10.10.13', :primary => false, :cpus => $cpus, :memory => $memory }
]

# write ansible inventory based on boxes
File.open('vagrant-ansible-inventory','w') do |f|
  boxes.each {|v| f.puts("[#{v[:type]}]\n#{v[:name]} ansible_ssh_host=#{v[:ip]} ansible_ssh_user=vagrant ansible_ssh_private_key_file=~/.vagrant.d/insecure_private_key\n") }
end

# Find the current vagrant directory.
vagrant_dir = File.expand_path(File.dirname(__FILE__))

# Vagrantfile API/syntax version.
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |c|
  boxes.each do |v|

    # Configure virtual machine options
    c.vm.define v[:name], primary: v[:primary] do |config|
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

      if Vagrant.has_plugin?("vagrant-hostmanager")
        config.hostmanager.enabled = true
        config.hostmanager.manage_host = true
        config.hostmanager.ignore_private_ip = false
        config.hostmanager.include_offline = true
        config.hostmanager.aliases = v[:aliases]
        config.vm.provision :hostmanager
      end

      # SSH Set up
      config.ssh.forward_agent = true

      config.vm.box = box
      config.vm.hostname = v[:name]
      config.vm.box_check_update = false

      config.vm.network :private_network, ip: v[:ip]

      # Configure virtual machine setup
      config.vm.provider :virtualbox do |vb|
        vb.gui = $gui
        vb.memory = v[:memory]
        vb.cpus = v[:cpu]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      end

      config.vm.provider :vmware_fusion do |vw|
        vw.gui = $gui
      end

      config.vm.synced_folder "shared", "/data/shared", id: "data", :nfs => true, :mount_options => ['nolock,vers=3,udp']
    end
  end

  # Provision vagrant box with Ansible
  c.vm.provision "ansible" do |ansible|
    ansible.playbook = vagrant_dir + "/playbooks/site.yml"
    ansible.inventory_path = "vagrant-ansible-inventory"
    ansible.host_key_checking = false
    #ansible.limit = 'all'
    ansible.extra_vars = { clear_module_cache: true, ansible_ssh_user: 'vagrant' }
    ansible.raw_ssh_args = '-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o IdentitiesOnly=yes'
    ansible.verbose = ''
    #ansible.skip_tags = "non-local"
    # ansible.tags = 'test'
    # ansible.start_at_task = ''
  end

  ## Use serverspec for testing
  # config.vm.provision "serverspec" do |spec|
  #   spec.pattern = 'spec/*_spec.rb'
  # end
end
