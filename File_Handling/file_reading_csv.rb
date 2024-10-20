require 'csv'

csv_file_path = 'sample.csv'
start_time = Time.now

CSV.foreach(csv_file_path, headers: true) do |row|
end

end_time = Time.now
time_taken = end_time - start_time
puts "Time taken to read the CSV file using CSV.foreach: #{time_taken.round(2)} seconds."
