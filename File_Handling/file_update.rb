require 'csv'

csv_file_path = 'sample.csv'
id_to_update = 346
new_age = 26      


start_time = Time.now


rows = CSV.read(csv_file_path, headers: true)

rows.each do |row|
  if row['ID'].to_i == id_to_update
    row['Age'] = new_age  
    puts "Updated ID #{id_to_update}'s age to #{new_age}."
  end
end


CSV.open(csv_file_path, 'w') do |csv|
  csv << rows.headers  
  rows.each do |row|
    csv << row          
  end
end


finish_time = Time.now


time_taken = finish_time - start_time
puts "Time taken to update the CSV file: #{time_taken.round(2)} seconds."
