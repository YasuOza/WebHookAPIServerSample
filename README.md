# WebHookAPISereverSample

Sinatra is a DSL for quickly creating web applications in Ruby with minimal effort:

http://www.sinatrarb.com/intro.html

## Set up your server
Set your values into `config/settings.rb`.

## How to start server

Install dependencies.

```shell
$ gem isntall sinatra
$ gem install twitter
```

Run as an instance server.

```shell
$ ruby server.rb
```

Run as a daemonized server

```shell
$ rackup config.ru -D
```

## Deploy your application
Set your remote server info into `config/deploy.rb`

### Install capistrano

```shell
$ gem install capistrano
$ gem install capistrano_colors
$ echo "require 'capistrano_colors'" >> ~/.caprc
```

### Deploy

```shell
$ cap deploy:setup
$ cap deploy:update_code
$ cap deploy:create_symlink
$ cap deploy:start
```
