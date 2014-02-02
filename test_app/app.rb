require_relative '../lib/veins'

Dir.glob(File.join(__FILE__.gsub('.rb', ''), '**/*.rb')).each { |f| require f }