require 'serverspec'

set :backend, :exec

%w(git zsh).each do |p|
  describe package(p) do
    it { should be_installed }
  end
end
