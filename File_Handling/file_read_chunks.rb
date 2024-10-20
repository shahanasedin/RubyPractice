csv_file_path = 'sample.csv'
start_time = Time.now

File.open(csv_file_path, 'r') do |file|
  while (chunk = file.read(1024))  
  end
end

end_time = Time.now
time_taken = end_time - start_time
puts "Time taken to read the CSV file using File.read in chunks: #{time_taken.round(2)} seconds."
