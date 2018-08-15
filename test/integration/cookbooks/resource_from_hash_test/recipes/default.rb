#
# Cookbook Name:: resource_from_hash_test
# Recipe:: default
#
# Copyright (C) 2014, Oregon State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

data = {
  resource: 'package',
  name: 'git',
  attributes: {
    action: :upgrade
  }
}

resource_from_hash 'test' do
  attrs_hash data
  action :do
end

db = data_bag_item('resource_from_hash_test', 'test')

resource_from_hash 'db_test' do
  attrs_hash db.to_hash
  action :do
end

serv = {
  resource: 'service',
  name: 'sshd',
  attributes: {
    supports: { restart: true, stop: true, start: true },
    action: [:start, :enable]
  }
}

resource_from_hash 'service_test' do
  attrs_hash serv
  action :do
end
