require 'open-uri'
require 'csv'
require 'json'

# get the csv file from github and save it
download = open('https://raw.githubusercontent.com/trustpair/jobs/master/ruby/data.csv')
csvpath = 'data.csv'
IO.copy_stream(download, csvpath)


# read the csv
sirets = ""
csv_options = { col_sep: ',', headers: :first_row }
CSV.foreach(csvpath, csv_options) do |row|
  sirets << "\%3A\%22" + row['siret'] + "\%22\%20OR\%20siret" # format for request into the url
  # puts "#{row['company']} - #{row['siret']}"
end
sirets = sirets[0..-14]


# API
url = "https://data.opendatasoft.com/api/v2/catalog/datasets/sirene%40public/records?where=siret#{sirets}&rows=100&select=l1_normalisee%2C%20siret%2C%20apen700%2C%20libnj%2C%20dcren&pretty=false"

jsonpath = 'sirene.json'
sirene_serialized = open(jsonpath).read
# sirene_serialized = open(url).read
# IO.copy_stream(sirene_serialized, jsonpath)
sirene = JSON.parse(sirene_serialized)

puts sirene['records'][12]['record']['fields']['l1_normalisee']
puts sirene['records'][35]['record']['fields']['l1_normalisee']



# https://data.opendatasoft.com/api/v2/catalog/datasets/sirene%40public/records?where=siret%3A%2260203644404227%22%20OR%20siret%3A%2234145938600213%22%20OR%20siret%3A%2266204244900014%22&rows=10&select=l1_normalisee%2C%20siret%2C%20apen700%2C%20libnj%2C%20dcren&pretty=false&timezone=UTC


# %3A%2260203644404227%22%20OR%20siret%3A%2234145938600213%22
# %3A%2260203644404227%22%20OR%20siret%3A%2234145938600213%22%20OR%20siret%3A%2266204244900014%22
