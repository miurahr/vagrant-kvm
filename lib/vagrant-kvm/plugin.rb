begin
  require "vagrant"
rescue LoadError
  raise "The Vagrant KVM plugin must be run within Vagrant."
end

# This is a sanity check to make sure no one is attempting to install
# this into an early Vagrant version.
if Vagrant::VERSION < "1.4.0"
  raise "The Vagrant KVM plugin is only compatible with Vagrant 1.4+"
end

module VagrantPlugins
  module ProviderKvm
    class Plugin < Vagrant.plugin("2")
      name "KVM provider"
      description <<-EOF
      The KVM provider allows Vagrant to manage and control
      QEMU/KVM virtual machines with libvirt.
      EOF

      config(:kvm, :provider) do
        require_relative "config"
        Config
      end

      provider(:kvm) do
        # Setup logging and i18n
        setup_logging
        setup_i18n

        # Return the provider
        require_relative "provider"
        Provider
      end

      guest_capability("linux", "mount_p9_shared_folder") do
        require_relative "cap/mount_p9"
        Cap::MountP9
      end

      synced_folder("p9", 20) do
        require_relative "synced_folder"
        SyncedFolder
      end

      # This initializes the internationalization strings.
      def self.setup_i18n
        lang = ENV['LANG']
        case lang
        when /^en/
          catalog = "locales/en.yml"
        when /^ja/
          catalog = "locales/ja.yml"
        else
          catalog = "locales/en.yml"
        end
        I18n.load_path << File.expand_path(catalog, ProviderKvm.source_root)
        I18n.reload!
      end

      # This sets up our log level to be whatever VAGRANT_LOG is.
      def self.setup_logging
        require "log4r"

        level = nil
        begin
          level = Log4r.const_get(ENV["VAGRANT_LOG"].upcase)
        rescue NameError
          # This means that the logging constant wasn't found,
          # which is fine. We just keep `level` as `nil`. But
          # we tell the user.
          level = nil
        end

        # Some constants, such as "true" resolve to booleans, so the
        # above error checking doesn't catch it. This will check to make
        # sure that the log level is an integer, as Log4r requires.
        level = nil if !level.is_a?(Integer)

        # Set the logging level on all "vagrant" namespaced
        # logs as long as we have a valid level.
        if level
          logger = Log4r::Logger.new("vagrant_kvm")
          logger.outputters = Log4r::Outputter.stderr
          logger.level = level
          logger = nil
        end
      end
    end
  end
end
