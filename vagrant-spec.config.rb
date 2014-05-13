Vagrant::Spec::Acceptance.configure do |c|
  c.provider 'kvm', box: 'spec/test_files/dummy-kvm.box'
end
