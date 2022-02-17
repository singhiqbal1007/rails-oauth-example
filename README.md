## development environment locally
Build development images: dip compose build <br>
Create Database: dip run rails db:create <br>
Start development server: dip rails s



## production environment locally
Create credentials for production environment <br>
Got to app/config/envrionments/production.rb and comment below line
`config.force_ssl = false` <br>
Build production images: docker-compose -f docker-compose-prod.yml build <br>
Create Database: docker-compose -f docker-compose-prod.yml run web_prod rails db:create <br>
Run Migrations: docker-compose -f docker-compose-prod.yml run web_prod rails db:migrate <br>
Start Server: docker-compose -f docker-compose-prod.yml up <br>
