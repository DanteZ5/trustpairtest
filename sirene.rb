require 'open-uri'
require 'csv'
require 'json'

results = {valid_sirets: 0, invalid_sirets: 0, before_1950: 0, between_1950_and_1975: 0, between_1976_and_1995: 0, between_1996_and_2005: 0, after_2005: 0 }


# generate output.json
def generate_output(sirene)
  output = { output: []}
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
end


# calcul expected results
def results_calculation(sirene, sirets_counter, results)
  results[:valid_sirets] = sirene['records'].length
  results[:invalid_sirets] = sirets_counter - sirene['records'].length

  sirene['records'].each do |record|
    creation_year = record['record']['fields']['dcren'][0..3].to_i
    if creation_year > 2005
      results[:after_2005] += 1
    elsif creation_year >= 1996
      results[:between_1996_and_2005] += 1 # guess there is a mistake in readme
    elsif creation_year >= 1976
      results[:between_1976_and_1995] += 1
    elsif creation_year >= 1950
      results[:between_1950_and_1975] += 1
    else
      results[:before_1950] += 1
    end
  end
  return results
end

# display results
def show_results(results)
  puts "* Number of valid SIRETs: [#{results[:valid_sirets]}]"
  puts "* Number of invalid SIRETs: [#{results[:invalid_sirets]}]"
  puts "* Number of companies created before 1950: [#{results[:before_1950]}]"
  puts "* Number of companies created between 1950 and 1975: [#{results[:between_1950_and_1975]}]"
  puts "* Number of companies created between 1976 and 1995: [#{results[:between_1976_and_1995]}]"
  puts "* Number of companies created before 1995 and 2005: [#{results[:between_1996_and_2005]}]"
  puts "* Number of companies created after 2005: [#{results[:after_2005]}]"
end


# get the csv file from github and save it
download = open('https://raw.githubusercontent.com/trustpair/jobs/master/ruby/data.csv')
csvpath = 'data.csv'
IO.copy_stream(download, csvpath)
puts "data.csv saved from github"

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

# desactive if change
# sirene_serialized = open(jsonpath).read

# active this one for request from the web
puts "API request from OpenDataSoft"
sirene_serialized = open(url).read

# active this to save
# sirene_serialized = open(url)
# IO.copy_stream(sirene_serialized, jsonpath)

sirene = JSON.parse(sirene_serialized)
generate_output(sirene)
results = results_calculation(sirene,sirets_counter, results)

puts "Data processing complete"
show_results(results)
