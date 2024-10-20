csv_file_path = 'sample.csv'
start_time = Time.now

File.open(csv_file_path, 'r') do |file|
  file.each_line do |line|
  end
end

end_time = Time.now
time_taken = end_time - start_time
puts "Time taken to read the CSV file using File.open with each_line: #{time_taken.round(2)} seconds."
