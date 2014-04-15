module VagrantKvmHelper

  def create_vagrantfile
    File.open('Vagrantfile', 'w') do |file|
      file.write <<-RUBY
        Vagrant.require_plugin 'vagrant-kvm'

        Vagrant.configure('2') do |config|
          config.vm.box = 'vagrant-kvm-specs'
          config.vm.network :private_network, ip: '192.168.50.2'
        end
      RUBY
    end
  end

  def vagrant_up
    silent_exec('bundle exec vagrant up --provider=kvm')
  end

  def vagrant_halt
    silent_exec('bundle exec vagrant halt')
  end

  def vagrant_destroy
    silent_exec('bundle exec vagrant destroy -f')
  end

  def pool_files
    Dir["/home/#{ENV['USER']}/.vagrant.d/tmp/storage-pool/*"]
  end

  private

  def silent_exec(cmd)
    gemfile = File.dirname(__FILE__)+"../../../Gemfile"
    cmdline = 'VAGRANT_FORCE_BUNDLER=1 BUNDLE_GEMFILE='+gemfile+' '
    cmdline << cmd
    cmdline << ' 2>&1' unless !!ENV['DEBUG']
    `#{cmdline}`
  end

end # VagrantKvmHelper
