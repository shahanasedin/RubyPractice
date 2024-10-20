require 'csv'
require 'date'

csv_file_path = 'sample.csv'

def generate_random_dob(age)
  current_year = Time.now.year
  birth_year = current_year - age
  birth_month = rand(1..12)


  days_in_month = Date.new(birth_year, birth_month, -1).day  
  birth_day = rand(1..days_in_month)

  dob = Date.new(birth_year, birth_month, birth_day)

  day_with_suffix = add_ordinal_suffix(birth_day)

  "#{day_with_suffix} #{dob.strftime('%B')} #{birth_year}"
end

def add_ordinal_suffix(day)
  if (11..13).include?(day % 100)
    "#{day}th"
  else
    case day % 10
    when 1; "#{day}st"
    when 2; "#{day}nd"
    when 3; "#{day}rd"
    else    "#{day}th"
    end
  end
end

def generate_row(id)
  age = rand(18..65)
  dob = generate_random_dob(age)
  [id, age, dob]
end

start = Time.now

CSV.open(csv_file_path, 'w') do |csv|
  csv << ['ID', 'Age', 'Date of Birth']
  (1..5_000_000).each do |id|  
    csv << generate_row(id)
    puts "#{id} rows written..." if id % 1_000_000 == 0
  end
end

finish = Time.now

puts "CSV file '#{csv_file_path}' with 50 million rows (ID, Age, and Date of Birth) has been created."
puts "Time taken to write the file: #{(finish - start).round(2)} seconds."
