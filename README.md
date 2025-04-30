# Rails Oauth Example
This is an example of rails OAUTH application running in docker and deployed on heroku. <br>
See demo at: [rails-oauth-example.onrender.com](https://rails-oauth-example.onrender.com/)

# Run Locally
### prequisites
* [docker](https://docs.docker.com/get-docker/)
* [dip](https://github.com/bibendi/dip)


## Run development environment locally using docker-compose
### Setup
Build development images:
```bash
$ dip compose build  
```

Create Database:
```bash
$ dip run rails db:create
```

### Run
Start development server:
```
$ dip rails s  
```

## Run production environment locally using docker-compose
### Setup
Build production images:
```bash
$ docker-compose -f docker-compose-prod.yml build
```

Create new credentials for production environment ->  https://edgeguides.rubyonrails.org/security.html#custom-credentials

Go to app/config/envrionments/production.rb and comment the line  `config.force_ssl = true`

Create Database:
```bash
$  docker-compose -f docker-compose-prod.yml run web_prod rails db:create
```
Migrate Database:
```bash
$ docker-compose -f docker-compose-prod.yml run web_prod rails db:migrate
```
Seed Database:
```bash
$ docker-compose -f docker-compose-prod.yml run web_prod rails db:seed
```

### Run
Start production server:
```
$ docker-compose -f docker-compose-prod.yml up
```

## Run production environment locally using kubernetes
```bash
$ kctl apply -f kubernetes
```

Server is running in `localhost:30050`
