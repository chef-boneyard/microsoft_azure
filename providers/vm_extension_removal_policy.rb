include Azure::Cookbook
require 'json'

action :set do
  begin
    # get the path of extension config file
    if node['platform_family'] == 'windows'
      extension_path = Dir["C:/Packages/Plugins/Chef.Bootstrap.WindowsAzure.ChefClient/*"].last
      config_path = Dir[extension_path+"/RuntimeSettings/*.settings"].last
    else
      extension_path = Dir["/var/lib/waagent/Chef.Bootstrap.WindowsAzure.LinuxChefClient-*"].last
      config_path = Dir[extension_path+"/config/*.settings"].last
    end

    # config file is in json format. So deserialize it
    deserialized_json = deserialize_json(config_path)
    deserialized_json["runtimeSettings"][0]["handlerSettings"]["publicSettings"]["deleteChefConfig"] = new_resource.delete_chef_config
    deserialized_json["runtimeSettings"][0]["handlerSettings"]["publicSettings"]["uninstallChefClient"] = new_resource.uninstall_chef_client

    File.write(config_path, deserialized_json.json)
  rescue => error
    Chef::Log.error("#{error.message}")
  end
end

def deserialize_json(file)
  # User may give file path or file content as input.
  normalized_content = File.read(file) if File.exists?(file)

  begin
    JSON.parse(normalized_content)
  rescue JSON::ParserError => e
    normalized_content = escape_unescaped_content(normalized_content)
    JSON.parse(normalized_content)
  end
end

def escape_unescaped_content(file_content)
  lines = file_content.lines.to_a
  # convert tabs to spaces -- technically invalidates content, but
  # if we know the content in question treats tabs and spaces the
  # same, we can do this.
  untabified_lines = lines.map { | line | line.gsub(/\t/," ") }

  # remove whitespace and trailing newline
  stripped_lines = untabified_lines.map { | line | line.strip }
  escaped_content = ""
  line_index = 0

  stripped_lines.each do | line |
    escaped_line = line

    # assume lines ending in json delimiters are not content,
    # and that lines followed by a line that starts with ','
    # are not content
    if !!(line[line.length - 1] =~ /[\,\}\]]/) ||
        (line_index < (lines.length - 1) && lines[line_index + 1][0] == ',')
      escaped_line += "\n"
    else
      escaped_line += "\\n"
    end

    escaped_content += escaped_line
    line_index += 1
  end

  escaped_content
end