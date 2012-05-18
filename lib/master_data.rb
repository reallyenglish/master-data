require "singleton"
require "active_support/inflector"

["master_data", "master_data_item", "master_data_parent"].each do |file|
  require File.dirname(__FILE__) + "/master_data/#{file}"
end
