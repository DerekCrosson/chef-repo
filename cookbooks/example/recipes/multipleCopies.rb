# NOTE: This file would be in /var/save/multipleCopies if it was on the server that was provisioned for the test
SECRET_FILE_ROOT_PATH = "/var/save/"
SECRET_FILE_DIRECTORY_PREFIX = "multipleCopy"
NUMBER_OF_SECRET_FILES = 3
SECRET_FILENAME = "secrets.txt"

(1..NUMBER_OF_SECRET_FILES).each do |secret_file_number|
  directory_path = "#{SECRET_FILE_ROOT_PATH}#{SECRET_FILE_DIRECTORY_PREFIX}#{secret_file_number}"

  directory directory_path do
    owner 'ubuntu'
    group 'root'
    mode '0755'
    recursive true
    action :create
  end

  file "#{directory_path}/#{SECRET_FILENAME}" do
    content '' # empty secret file
    owner 'ubuntu'
    group 'root'
    mode '0755'
    action :create_if_missing
  end
end

# Check modified timestamps
latest_file_updated = NUMBER_OF_SECRET_FILES.times.sort_by { |secret_file_number| ::File.mtime("#{SECRET_FILE_DIRECTORY_PREFIX}#{secret_file_number + 1}/#{SECRET_FILENAME}") rescue 0 }
newest_content = ::File.read("#{SECRET_FILE_ROOT_PATH}#{SECRET_FILE_DIRECTORY_PREFIX}#{latest_file_updated + 1}/#{SECRET_FILENAME}")

# Not sure if this is the best place to do this, would prefer to only have one loop in the recipe if possible
(1..NUMBER_OF_SECRET_FILES).each do |secret_file_number|
  file "#{SECRET_FILE_ROOT_PATH}#{SECRET_FILE_DIRECTORY_PREFIX}#{secret_file_number}/#{SECRET_FILENAME}" do
    content newest_content
    owner 'root'
    group 'root'
    mode '0755'
  end
end
