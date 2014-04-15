require 'spec_helper'
require "vagrant-kvm/synced_folder"

describe  VagrantPlugins::ProviderKvm::SyncedFolder do
  let(:machine) do
    double("machine").tap do |m|
    end
  end

  subject { described_class.new }

  it "should be with kvm provider" do
    machine.stub(provider_name: :kvm)
    expect(subject).to be_usable(machine)
  end

end
