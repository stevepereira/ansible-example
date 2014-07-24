require 'yaml'

read_yaml = ->(fname) do
  begin
    YAML.load(File.read(File.join(File.dirname(__FILE__), fname)))
  rescue Errno::ENOENT
    {}
  end
end

STDOUT.sync = true

if not File.exists? "settings.yml"
    config = read_yaml.('example.settings.yml')
else
    config = read_yaml.('settings.yml')
end

task :test do
  puts "Vagrant: #{config['vagrant']['version']}"
end

notify = 'terminal-notifier -message SUCCESS || terminal-notifier -message FAILED'

desc "Default task => install dependencies (:homebrew) and start (:vagrant)"
task :default => ["setup:vagrant"]

namespace :homebrew do
  task :install => [:xcode_install, :brew_install, :brew_update, :install_ansible, :install_virtualbox, :install_vagrant, :install_terminal_notifier]
  task :update => [:brew_upgrade]

  desc "installs xcode cli"
  task :xcode_install do
    if not File.exists? "/Applications/Xcode.app/Contents/Developer/usr/bin/gcc"
      puts "+++ Installing xcode"
      sh "xcode-select --install"
    else
      puts "*** CLI tools already installed."
    end
  end

  desc "installs homebrew"
  task :brew_install do
    if not File.exists? "/usr/local/bin/brew"
      puts "+++ Installing homebrew"
      sh "ruby -e $(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
    else
      puts "*** Homebrew already installed."
    end
  end

  desc "updates homebrew package list"
  task :brew_update => [:brew_install] do
    puts "+++ Updating homebrew"
    sh "brew update"
    sh "tap phinze/homebrew-cask"
    sh "brew update"    
  end

  desc "installs ansible"
  task :install_ansible => [:brew_install, :brew_update] do
    if not File.exists? "/usr/local/bin/ansible"
      puts "+++ Installing Ansible"
      sh "brew install ansible"
      sh "brew switch ansible #{config['ansible']['version']}"
    else
      puts "*** Ansible already installed, version:"
      sh "ansible --version"
    end
  end

  desc "installs virtualbox"
  task :install_virtualbox => [:brew_install, :brew_update] do
    if not File.exists? "/usr/bin/VBoxManage"
      puts "+++ Installing Virtualbox"
      sh "brew cask install virtualbox"
      sh "brew switch virtualbox #{config['virtualbox']['version']}"
    else
      puts "*** Virtualbox already installed, version:"
      sh "VBoxManage -v"
    end
  end

  desc "installs vagrant"
  task :install_vagrant => [:brew_install, :brew_update] do
    if not File.exists? "/Applications/Vagrant/bin/vagrant"
      puts "+++ Installing Vagrant"
      sh "brew cask install vagrant"
      sh "brew switch vagrant #{config['vagrant']['version']}"
    else
      puts "*** Vagrant already installed, version:"
      sh "vagrant -v"
    end
  end

  desc "installs terminal notifier"
  task :install_terminal_notifier => [:brew_install, :brew_update] do
    if not File.exists? "/usr/local/bin/terminal-notifier"
      puts "+++ Installing Terminal-notifier"
      sh "brew install terminal-notifier"
    else
      puts "*** Terminal-notifier already installed."
      sh "terminal-notifier |head -n1 |awk '{ print $2}'"
    end
  end

  desc "upgrades all homebrew packages"
  task :brew_upgrade => [:brew_update] do
      sh "brew cleanup"
  end
end

namespace :setup do
  Rake::Task["homebrew:install"].invoke
  task :vagrant => [:settings, :vagrant_plugins, :vagrant_up, :vagrant_provision]

  desc "copy settings example if settings missing"
  task :settings do
    if not File.exists? "settings.yml"
      sh "cp example.settings.yml settings.yml"
    end
  end

  desc "vagrant plugins"
  task :vagrant_plugins do
    plugins = ["cachier", "vbguest", "pristine", "hostsupdater", "triggers"]
    plugins.each do |p|
      command = "vagrant plugin list |grep #{p}"
      unless system( command )
        sh "vagrant plugin install vagrant-#{p}"
      end
    end
  end

  desc "vagrant up"
  task :vagrant_up do
    command = "vagrant status |grep running"
    unless system( command )
      sh "time vagrant up && #{notify}"
    end
  end

  desc "vagrant provision"
  task :vagrant_provision do
    sh "time vagrant provision && #{notify}"
  end
end
