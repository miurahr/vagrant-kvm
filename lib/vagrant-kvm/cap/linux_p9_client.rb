module VagrantPlugins
  module ProviderKvm
    module Cap
      class P9Client

        def self.p9_module_installed(machine)
          if !machine.communicate.test("grep 9p /proc/filesystems")
            machine.communicate.sudo("modprobe 9p")
          end
          machine.communicate.test("grep 9p /proc/filesystems")
        end

      end
    end
  end
end
