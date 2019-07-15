require_relative '../../spec_helper'

describe 'resource_from_hash_test::default' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        stub_data_bag_item('resource_from_hash_test', 'test').and_return(
          id: 'test',
          name: 'zsh',
          resource: 'package',
          attributes: {}
        )
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to do_resource_from_hash('test')
      end
    end
  end
end
