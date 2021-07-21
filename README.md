# Minesweeper API

This is an API for creating a minesweeper board and providing information on each cell.

* Ruby version : 2.7.2

## to start a server running this api on your local machine

 First fork and clone this repository to your machine:

 ```
  git clone git@github.com:{YOUR-GITHUBNAME-HERE}/minesweeper-backend.git
 ```

 Next install all dependencies:

 ```
  bundle install
 ```

 Next get the database ready with:

 ```
  rails db:migrate
  rails db:seed
 ```

 Finally start the server on your local machine:

 ```
  rails s
 ```

 If you want to use the frontend I made with this API check out:

 https://github.com/kevinjung2/minesweeper-frontend
