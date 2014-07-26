# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative 'spec_helper'

describe package('ufw') do
  it { should be_installed }
end

describe service('ufw') do
  it { should be_enabled }
  it { should be_running }
end

describe port(22) do
  it { should be_listening }
end

describe port(80) do
  it { should be_listening }
end

describe port(8080) do
  it { should be_listening }
end

# describe port(443) do
#   it { should be_listening }
# end

# describe port(8443) do
#   it { should be_listening }
# end
