# -*- mode: ruby -*-
# vi: set ft=ruby :

# Set box configuration options
box = 'puphpet/ubuntu1404-x64'
memory = 512
gui = false
cpus = 2

# update vagrant-ansible-inventory to match the config below
# default config uses a vip 10.10.10.10 that should be configured for all fqdns
boxes = [
  { :name => 'lb-01', :aliases => ['{{ vip }}.xip.io', 'www.{{ vip }}.xip.io', 'static.{{ vip }}.xip.io', 'app.{{ vip }}.xip.io', 'lb-01.{{ vip }}.xip.io'], :type => :loadbalancer, :ip => '10.10.10.11', :primary => true, :cpus => $cpus, :memory => $memory },
  { :name => 'web-01', :aliases => ['web-01.{{ vip }}.xip.io'], :type => :webserver, :ip => '10.10.10.12', :primary => false, :cpus => $cpus, :memory => $memory },
  { :name => 'app-01', :aliases => ['app-01.{{ vip }}.xip.io'], :type => :appserver, :ip => '10.10.10.13', :primary => false, :cpus => $cpus, :memory => $memory }
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

      # Provision vagrant box with Ansible
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
  end

  # # Local Machine Hosts
  # #
  # # Harvested from: https://github.com/10up/varying-vagrant-vagrants/blob/master/Vagrantfile
  # #
  # # If the Vagrant plugin hostsupdater (https://github.com/cogitatio/vagrant-hostsupdater) is
  # # installed, the following will automatically configure your local machine's hosts file to
  # # be aware of the domains specified below. Watch the provisioning script as you may be
  # # required to enter a password for Vagrant to access your hosts file.
  # if Vagrant.has_plugin?("vagrant-hostsupdater")
  #   # Capture the paths to all vvv-hosts files under the www/ directory.
  #   paths = [vagrant_dir + '/vagrant-ansible-inventory']
  #   # Dir.glob(vagrant_dir + '/vhosts/vhosts').each do |path|
  #   #   paths << path
  #   # end

  #   # Parse through the vvv-hosts files in each of the found paths and put the hosts
  #   # that are found into a single array.
  #   hosts = []
  #   paths.each do |path|
  #     new_hosts = []
  #     file_hosts = IO.read(vagrant_dir + '/vagrant-ansible-inventory').split( "\n" )
  #     file_hosts.each do |line|
  #       if line[0..0] != "#"
  #         new_hosts << line
  #       end
  #     end
  #     hosts.concat new_hosts
  #   end

  #   # Pass the final hosts array to the hostsupdate plugin so it can perform magic.
  #   config.hostsupdater.aliases = hosts

  # end

  ## Use serverspec for testing
  # config.vm.provision "serverspec" do |spec|
  #   spec.pattern = 'spec/*_spec.rb'
  # end
end
