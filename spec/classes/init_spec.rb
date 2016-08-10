require 'spec_helper'
describe 'ubuntucommon' do

  context 'with defaults for all parameters' do
    it { should contain_class('ubuntucommon') }
  end
end
