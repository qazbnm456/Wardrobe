desc "Import images to database"
namespace :docker do
  task import_images: :environment do
    cmd = "docker images | awk '{ if(NR!=1) {print $1 \",\" $2} }'"
    stdout, _, _ = Open3.capture3(cmd)
    available = stdout.split("\n")
    available = available.map { |ele| ele.split(",") }.group_by { |e| e[0] }.map { |k, v| [k, v.map(&:last)] }

    connection = ActiveRecord::Base.connection

    available.each do |name, tags|
      tags.each do |tag|
        puts "Processing: #{name}:#{tag}"
        result = connection.execute "SELECT COUNT(`name`) FROM `images` WHERE `name`='#{name}' AND `tag`='#{tag}';"
        if result.first[0] == 0
          puts "Prepare to insert #{name}:#{tag} to images table!"
          connection.execute "INSERT INTO `images` (`name`, `tag`, `description`) VALUES ('#{name}', '#{tag}', '#{name}');"
          puts "...#{name}:#{tag} done!"
        else
          puts "...#{name}:#{tag} does not to be processed!"
        end
      end
    end
    puts "All done!"
  end
end
