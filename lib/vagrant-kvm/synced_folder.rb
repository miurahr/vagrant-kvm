module VagrantPlugins
  module ProviderKvm
    class SyncedFolder < Vagrant.plugin("2", :synced_folder)
      def usable?(machine)
        # These synced folders only work if the provider if KVM
        machine.provider_name == :kvm
      end

      def prepare(machine, folders, _opts)
        defs = []
        folders.each do |id, data|
          # access_mode can be squash, mapped, or passthrough
          accessmode = data.has_key?(:access_mode)? data[:access_mode] : 'squash'
          accessmode = 'squash' unless accessmode == 'mapped' || accessmode == 'passthrough'
          defs << {
            :mount_tag => id,
            :hostpath => data[:hostpath].to_s,
            :accessmode => accessmode
          }
        end

        driver(machine).share_folders(defs)

        if driver(mahchine).redhat? or driver(machine).suse? or driver(machine).arch?
          work_around_selinux_libvirt_bug!(defs)
        end
      end

      def enable(machine, folders, _opts)
        # Go through each folder and mount
        machine.ui.info("mounting p9 share in guest")
        # Only mount folders that have a guest path specified.
        mount_folders = {}
        folders.each do |id, opts|
          mount_folders[id] = opts.dup if opts[:guestpath]
        end
        common_opts = {
          :version => '9p2000.L',
        }
        # Mount the actual folder
        machine.guest.capability(
            :mount_p9_shared_folder, mount_folders, common_opts)
      end

      def cleanup(machine, opts)
        driver(machine).clear_shared_folders if machine.id && machine.id != ""
      end

      protected

      def work_around_selinux_libvirt_bug!(defs)
        begin
          defs.each do |share|
            target = share[:hostpath]
            system('sudo semanage fcontext -a -t virt_content_t "#{target}(/.*)?"')
            system('sudo restorecon -R #{target}')
          end
        rescue
          # ignore it, maybe no policycoreutils-python package
        end
      end

      # This is here so that we can stub it for tests
      def driver(machine)
        machine.provider.driver
      end
    end
  end
end
