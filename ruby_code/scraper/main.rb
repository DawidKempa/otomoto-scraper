require_relative 'scraper'
require_relative 'exporter'
require_relative 'config'

puts "AVAILABLE BRANDS:"
AVAILABLE_BRANDS.each { |brand| puts "- #{brand}" }

print "Pick brand from list: "
brand_input = gets.chomp.downcase

unless AVAILABLE_BRANDS.include?(brand_input)
  puts "Inccorect brand!"
  exit
end

print "Number of pages to check? (default 1): "
pages_input = gets.chomp.to_i
pages_input = 1 if pages_input < 1

scraper = OtomotoScraper.new(brand_input, pages_input)
products = scraper.scrape


Exporter.to_csv(products)
Exporter.to_pdf(products, brand_input)

puts "Data was saved to output.csv and ruby.pdf"