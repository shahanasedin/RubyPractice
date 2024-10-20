csv_file_path = 'sample.csv'
start_time = Time.now

File.foreach(csv_file_path) do |line|
end

end_time = Time.now
time_taken = end_time - start_time
puts "Time taken to read the CSV file using File.foreach: #{time_taken.round(2)} seconds."
