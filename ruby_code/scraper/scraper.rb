require 'httparty'
require 'nokogiri'
require_relative 'config'
require_relative 'models/product'

class OtomotoScraper
  def initialize(brand, pages = 1)
    @brand = brand
    @pages = pages
    @base_url = "https://www.otomoto.pl/osobowe/#{brand}"
  end

  def scrape
    products = []
    (1..@pages).each do |page|
      response = fetch_page(page)
      products += parse_html(response.body)
    end
    products
  end

  private

  def fetch_page(page)
    url = @pages > 1 ? "#{@base_url}?page=#{page}" : @base_url  #uzywane jesli mamy więcej niż 1 strone, wtedy do bazowego url dodajemy strony
    HTTParty.get(url, { 
      headers: { 
        "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36" 
      }, 
    })
  end

  def parse_html(html)
    document = Nokogiri::HTML(html)
    html_products = document.css("article > section")  # sekcja w artukule do wyszukiwanai ofert
    
    #mapowanie kazdego produktu na obiekt Product
    html_products.map do |html_product|
      parse_product(html_product)      #zwraca obiekt Product
    end
  end

  def parse_product(html_product)
    brand = html_product.css("h2").first.text

    price_value = html_product.at_css("h3").text || ""
    currency = html_product.at_css("p.efzkujb2").text || "" 
    price = "#{price_value} #{currency}"

    fuel = html_product.css("dd[data-parameter='fuel_type']").text
    mileage = html_product.css("dd[data-parameter='mileage']").text
    gearbox = html_product.css("dd[data-parameter='gearbox']").text
    year = html_product.css("dd[data-parameter='year']").text
    location = html_product.at_css("dd.ooa-1jb4k0u p.ooa-oj1jk2").text

    url = html_product.css("a").first.attribute("href").value
    image = html_product.css("img").first.attribute("src").value

    Product.new(brand, price, fuel, mileage, gearbox, year, location, url, image)  
  end
end