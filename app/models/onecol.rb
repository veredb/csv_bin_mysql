require 'active_record'
require 'mysql-copy/acts_as_copy_target'
require 'ms_data_encoder/encode_for_copy'
require 'benchmark'
require 'csv'


class Onecol < ActiveRecord::Base
     acts_as_copy_target
end




ActiveSupport.on_load :active_record do
     require "mysql-copy/acts_as_copy_target"
     require "active_record"
end
ActiveRecord::Base.establish_connection(
        :adapter  => "mysql2",
        :host     => "localhost",
        :database => "csv_bin_mysql_development"
)

ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS `onecols`")
ActiveRecord::Base.connection.execute("CREATE TABLE `onecols` (`id` int(11) NOT NULL AUTO_INCREMENT, `wor` varchar(255), PRIMARY KEY (`id`))")

encoder = MsDataEncoder::EncodeForCopy.new

puts "Loading data to disk"
puts Benchmark.measure {

    CSV.foreach('lib/file4.csv', :headers => false) do |row|
      encoder.add [row]
    end
}


puts "inserting into db"
puts Benchmark.measure {
  Onecol.copy_from(encoder.get_io, :format => :binary, :columns => [:wor])
}
encoder.remove
