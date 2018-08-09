require 'bundler/setup'
require 'securerandom'

require 'revision_plate'
require_relative './app'

Encoding.default_external = 'UTF-8'

map '/site/sha' do
  run RevisionPlate::App.new("#{__dir__}/REVISION")
end

run Awsuserjump

