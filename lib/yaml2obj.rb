"""This script parses a yaml style config as follows:
	- yaml strings become variables
	- yaml hashes translate to objects with nested properties
All objects are declared as instance variables (@) by default
"""

require 'erb'
require 'json'
require 'yaml'

class Hash
  def to_o
    JSON.parse to_json, object_class: OpenStruct
  end
end

class YAML2Obj

  def parse(yamlfile, toplevelkey)
	# check for vagrant config file
	if File.exist?(yamlfile)
			begin
				# yaml_config = YAML.load(File.read(yamlfile))
				yaml_config = YAML.load(ERB.new(File.read(yamlfile)).result)
			rescue Exception => e
				warn("#{yaml_config} fails yaml syntax check!")
				raise("Error was #{e}")
			end
	else
		raise("Could not find config file! #{yamlfile}")
	end
	# check for toplevelkey section in config file and evaluate variables
	if !yaml_config[toplevelkey].nil?
		yaml_config[toplevelkey].each do |c,s|
			if yaml_config[toplevelkey][c].is_a?(Hash)
				eval "$#{c} = yaml_config[toplevelkey][c].to_o"
			else
				eval "$#{c} = '#{s}'"
			end
		end
	else
		raise("No #{toplevelkey} key found in your #{yamlfile}. Consult #{yamlfile}.yaml.sample or the README")
	end
  end

end