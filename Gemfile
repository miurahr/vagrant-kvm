source "https://rubygems.org"

gemspec

group :development do
  # We depend on Vagrant for development, but we don't add it as a
  # gem dependency because we expect to be installed within the
  # Vagrant environment itself using `vagrant plugin`.
  gem "vagrant", :git => "git://github.com/mitchellh/vagrant.git"
  gem 'vagrant-spec', git: "https://github.com/mitchellh/vagrant-spec.git"
  gem "log4r", '1.1.10'
end
