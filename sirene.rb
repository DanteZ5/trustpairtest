require 'open-uri'
require 'csv'
require 'json'

# variables to store datas
before_1950 = 0
between_1950_and_1975 = 0
between_1976_and_1995 = 0
between_1996_and_2005 = 0 # guess there is a mistake in readme
after_2005 = 0


# get the csv file from github and save it
download = open('https://raw.githubusercontent.com/trustpair/jobs/master/ruby/data.csv')
csvpath = 'data.csv'
IO.copy_stream(download, csvpath)

# read the csv
sirets_counter = 0
sirets = ""
csv_options = { col_sep: ',', headers: :first_row }
CSV.foreach(csvpath, csv_options) do |row|
  sirets << "\%3A\%22" + row['siret'] + "\%22\%20OR\%20siret" # format for request into the url
  sirets_counter += 1
  # puts "#{row['company']} - #{row['siret']}"
end
sirets = sirets[0..-14]

# API request
url = "https://data.opendatasoft.com/api/v2/catalog/datasets/sirene%40public/records?where=siret#{sirets}&rows=100&select=l1_normalisee%2C%20siret%2C%20apen700%2C%20libnj%2C%20dcren%2C%20numvoie%2C%20typvoie%2C%20libvoie%2C%20codpos%2C%20libcom&pretty=false"
jsonpath = 'sirene.json'
sirene_serialized = open(jsonpath).read
# sirene_serialized = open(url)
# IO.copy_stream(sirene_serialized, jsonpath)
sirene = JSON.parse(sirene_serialized)



# Creating Json
output = { output: []}
puts output[:output].class
sirene['records'].each do |record|
  output[:output] << {company_name: record['record']['fields']['l1_normalisee'],
                      siret: record['record']['fields']['siret'],
                      ape_code: record['record']['fields']['apen700'],
                      legal_nature: record['record']['fields']['libnj'],
                      date_of_creation: record['record']['fields']['dcren'],
                      address: "#{record['record']['fields']['numvoie']} #{record['record']['fields']['typvoie']} #{record['record']['fields']['libvoie']} #{record['record']['fields']['codpos']} #{record['record']['fields']['libcom']}"}
end


File.open('output.json', 'wb') do |file|
  file.write(JSON.generate(output))
end


# calculate creation dates
sirene['records'].each do |record|
  creation_year = record['record']['fields']['dcren'][0..3].to_i
  if creation_year > 2005
    after_2005 += 1
  elsif creation_year >= 1996
    between_1996_and_2005 += 1
  elsif creation_year >= 1976
    between_1976_and_1995 += 1
  elsif creation_year >= 1950
    between_1950_and_1975 += 1
  else
    before_1950 += 1
  end
end

# show results
puts "Data processing complete"
puts "* Number of valid SIRETs: [#{sirene['records'].length}]"
puts "* Number of invalid SIRETs: [#{sirets_counter - sirene['records'].length}]"
puts "* Number of companies created before 1950: [#{before_1950}]"
puts "* Number of companies created between 1950 and 1975: [#{between_1950_and_1975}]"
puts "* Number of companies created between 1976 and 1995: [#{between_1976_and_1995}]"
puts "* Number of companies created before 1995 and 2005: [#{between_1996_and_2005}]"
puts "* Number of companies created after 2005: [#{after_2005}]"

# https://data.opendatasoft.com/api/v2/catalog/datasets/sirene%40public/records?where=siret%3A%2260203644404227%22%20OR%20siret%3A%2234145938600213%22%20OR%20siret%3A%2266204244900014%22&rows=10&select=l1_normalisee%2C%20siret%2C%20apen700%2C%20libnj%2C%20dcren&pretty=false&timezone=UTC


# %3A%2260203644404227%22%20OR%20siret%3A%2234145938600213%22
# %3A%2260203644404227%22%20OR%20siret%3A%2234145938600213%22%20OR%20siret%3A%2266204244900014%22
