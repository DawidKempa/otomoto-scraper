require 'csv'
require 'prawn'
require 'open-uri'
require_relative 'config'
require_relative 'models/product'

class Exporter
  ITEM_HEIGHT = 200
  MARGIN_BETWEEN_ITEMS = 20

  def self.to_csv(products, filename = "output.csv")
    headers = ["brand", "price", "fuel", "mileage", "gearbox", "year", "location", "url", "image"]
    CSV.open(filename, "wb", write_headers: true, headers: headers) do |csv| 
      products.each { |product| csv << product }
    end
  end

  def self.to_pdf(products, brand, filename = "otomoto.pdf")
    Prawn::Document.generate(filename) do |pdf|
      setup_pdf(pdf, brand)
      add_products_to_pdf(pdf, products)
    end
  end

  private

  def self.setup_pdf(pdf, brand)
    pdf.font_families.update(PDF_FONT_PATH)
    pdf.font "DejaVu"
    add_watermark(pdf, brand)
  end

  def self.add_watermark(pdf, brand)
    watermark = File.join(WATERMARKS_DIR, "#{brand}.png") #dodajemy znak wodny w zaleznosci od wybranej marki
    return unless File.exist?(watermark)

    pdf.create_stamp("full_page_watermark") do
      pdf.transparent(0.15) do
        pdf.image watermark,
                at: [0, pdf.bounds.height],
                width: pdf.bounds.width,
                height: pdf.bounds.height
      end
    end
    pdf.repeat(:all) { pdf.stamp("full_page_watermark") }
  end

  def self.add_products_to_pdf(pdf, products)
    products.each do |product|
      if pdf.cursor < ITEM_HEIGHT + 50
        pdf.start_new_page
        pdf.move_down 20
      end

      available_height = pdf.cursor - 50

      pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width, height: [ITEM_HEIGHT, available_height].min) do
        add_product_image(pdf, product)
        add_product_details(pdf, product)
      end

      pdf.move_down MARGIN_BETWEEN_ITEMS
    end
  end

  def self.add_product_image(pdf, product)
  pdf.bounding_box([0, pdf.bounds.top], width: 150, height: pdf.bounds.height) do
    unless product.image.empty?
      begin
        image_data = URI.open(product.image, read_timeout: 10).read    # Pobiera zdjęcie z URL
        image = StringIO.new(image_data)
        
        pdf.image image,
                width: 140,
                height: pdf.bounds.height - 10,
                position: :center,
                vposition: :center,
                fit: [140, pdf.bounds.height - 10] # Zachowaj proporcje
      rescue OpenURI::HTTPError, Timeout::Error, SocketError => e
        pdf.text "Błąd ładowania zdjęcia", 
                align: :center, 
                valign: :center,
                size: 8
      rescue => e
        pdf.text "Nieobsługiwany format", 
                align: :center, 
                valign: :center,
                size: 8
      end
    else
      pdf.text "Brak zdjęcia", 
              align: :center, 
              valign: :center
    end
    pdf.stroke_bounds
  end
end

  def self.add_product_details(pdf, product)
    #skrócenie linku 
    display_url = product.url.gsub(/https?:\/\/(www\.)?/, '')[0..30]
    display_url += "..." if display_url.length > 30
    
    data = [
      ["Brand:", product.brand],
      ["Price:", product.price],
      ["Fuel:", product.fuel],
      ["Mileage:", product.mileage],
      ["Gearbox:", product.gearbox],
      ["Year:", product.year],
      ["Location:", product.location],
      ["Link:", display_url]
    ]

    row_height = pdf.bounds.height / data.size

    data.each_with_index do |(header, value), index|
      y_position = pdf.bounds.top - (index * row_height)

      add_detail_label(pdf, header, y_position, row_height)
      add_detail_value(pdf, value, y_position, row_height, header == "Link:" ? product.url : nil)
    end
  end

  def self.add_detail_label(pdf, text, y_position, height)
    pdf.bounding_box([150, y_position], width: 100, height: height) do
      pdf.text text, align: :center, 
                valign: :center, 
                size: 10
      pdf.stroke_bounds
    end
  end

  def self.add_detail_value(pdf, value, y_position, height, link = nil)
    pdf.bounding_box([250, y_position], width: pdf.bounds.width - 250, height: height) do
      if link
        pdf.text_box "<link href='#{link}'>#{value}</link>",
                  at: [0, height],
                  height: height,
                  align: :center,
                  valign: :center,
                  size: 10,
                  inline_format: true,
                  overflow: :shrink_to_fit
      else
        pdf.text value.to_s, align: :center,
                  valign: :center,
                  size: 10
      end
      pdf.stroke_bounds
    end
  end
end