require 'open-uri'
require 'csv'
require 'json'


# get the csv file from github and save it
download = open('https://raw.githubusercontent.com/trustpair/jobs/master/ruby/data.csv')
csvpath = 'data.csv'
IO.copy_stream(download, csvpath)


# read the csv

csv_options = { col_sep: ',', headers: :first_row }
CSV.foreach(csvpath, csv_options) do |row|
  # puts "#{row['company']} - #{row['siret']}"
end


# API
# https://data.opendatasoft.com/api/v2/catalog/datasets/sirene%40public/records?where=siret%3A%2260203644404227%22%20OR%20siret%3A%2234145938600213%22&rows=10&select=l1_normalisee%2C%20siret%2C%20apen700%2C%20libnj%2C%20dcren&pretty=false&timezone=UTC
jsonpath = 'sirene.json'
sirene_serialized = open(jsonpath).read
sirene = JSON.parse(sirene_serialized)

puts sirene['records'][0]['record']['fields']['l1_normalisee']
puts sirene['records'][1]['record']['fields']['l1_normalisee']

