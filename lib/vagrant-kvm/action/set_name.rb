module VagrantPlugins
  module ProviderKvm
    module Action
      class SetName
        def initialize(app, env)
          @logger = Log4r::Logger.new("vagrant::action::vm::setname")
          @app = app
        end

        def call(env)
          name = env[:machine].provider_config.name

          # If we already set the name before, then don't do anything
          sentinel = env[:machine].data_dir.join("action_set_name")
          if !name && sentinel.file?
            @logger.info("Default name was already set before, not doing it again.")
            return @app.call(env)
          end

          # If no name was manually set, then use a default
          if !name
            prefix = "#{env[:root_path].basename.to_s}_#{env[:machine].name}"
            prefix.gsub!(/[^-a-z0-9_]/i, "")
            name = prefix + "_#{(Time.now.to_f * 1000.0).to_i}_#{rand(100000)}"
          end

          # @todo raise error if name is taken in kvm
          # Verify the name is not taken
          # vms = env[:machine].provider.driver.read_vms
          #raise Vagrant::Errors::VMNameExists, :name => name if \
          #  vms.has_key?(name) && vms[name] != env[:machine].id
          #
          #if vms.has_key?(name)
          #  @logger.info("Not setting the name because our name is already set.")
          #else
          #  env[:ui].info(I18n.t(
          #    "vagrant.actions.vm.set_name.setting_name", name: name))
          #  env[:machine].provider.driver.set_name(name)
          #end

          @logger.info("Setting the name of the VM: #{name}")
          env[:machine].provider.driver.set_name(name)

          # Create the sentinel
          sentinel.open("w") do |f|
            f.write(Time.now.to_i.to_s)
          end

          @app.call(env)
        end

      end
    end
  end
end
