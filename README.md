Ruby web scraper for extracting car listings from Otomoto.pl and exporting to CSV/PDF formats

# Quick Start with Docker

docker-compose build
docker-compose run dev

# Inside container:

bundle install
ruby main.rb

# Configuration

AVAILABLE_BRANDS = ['bmw', 'audi', 'mercedes', 'toyota', 'volkswagen']

Place PNG files in water_marks/ named as brand_name.png (e.g., bmw.png)

# Output Files

After successful execution, the project folder will contain:

- `ruby.pdf` - Formatted report with all car listings including images
- `output.csv` - Raw data in CSV format
