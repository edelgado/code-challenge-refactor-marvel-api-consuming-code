# Code Exercise - Refactor code that talks to the Marvel API

By Enrique Delgado.

## Problem Statement

* Review the code below that uses the Marvel API (http://developer.marvel.com/).
* You may have to signup for a free account to test

### Tasks: 
* Refactor. Make something worth sharing. 
* Find the total number of characters in Marvel catalog
* Grab a character from the list and display their thumbnail url
* List just the character names in the comics id of 30090 and 162
* Return updated code and steps to generate answers in email attachment.

Code to refactor:

```ruby
require 'digest/md5'
require "net-http"
require "uri"

class Marvel
  attr_reader :public_key, :private_key

  def initialize(options={})
    @public_key='123'
    @private_key='ABCD123'
  end

  def get_the_characters
    uri = URI.parse("http://gateway.marvel.com")

    http =  Net::HTTP.new(uri.host, uri.port)
    request=Net::HTTP::Get.new("/v1/public/characters#{auth_params(public_key,private_key)}&limit=1")
    @response = http.request(request)
    @response.body
rescue
    nil
  end

def people_in_comics(comic_ids_array = [])
    comic_ids = to_csv(comic_ids_array)
    uri = URI.parse("http://gateway.marvel.com")
    http = Net::HTTP.new(uri.host, uri.port)


    request = Net::HTTP::Get.new("/v1/public/characters#{auth_params}&limit=1&comics=#{comic_ids}")

    @response = http.request(request)

    @response.body
  end

  def auth_params(publick,privatek)
      ts = Time.now.to_i
      hash = Digest::MD5.hexdigest("#{ts}#{privatek}#{publick}")
      "?ts=#{ts}#{ts}&apikey=#{publick}&hash=#{hash}"
  end

  def to_csv(array)
  output = ''
  is_first = true
  array.each do |x|
  unless is_first
  output = output + ','
  end
  output = output + x.to_s
  is_first = false
  end
  return output
  end

end
```

## Solution

### Quick Start

    $ bundle
    $ bundle exec rake
    $ ./bin/console

Sample usage:

 ```   
    > Marvel.set_config({public_key: 'c94d87eb20347745bbd4d3344530b76c', private_key: '9f6be4b65b1e66b654228e2f22aa822fac88e803'})
    > Marvel.total_characters # 1485
    > Marvel.sample_character_thumbnail # "http://i.annihil.us/u/prod/marvel/i/mg/3/00/4c003c66d3393.jpg"
    > Marvel.characters_in_comics(comic_ids: [30090, 162]) # ['Captain America','Captain Britain','Iron Man','Spider-Man','Thor']
```

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'marvel'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install marvel

### Usage

To use this gem, first configure it, by passing your Marvel API credentials (http://developer.marvel.com/)

    > require 'marvel'
    > Marvel.set_config({public_key: 'foo', private_key: 'bar'})

Once configured, you can do things like:

    > Marvel.total_characters # 1485
    > Marvel.sample_character_thumbnail # "http://i.annihil.us/u/prod/marvel/i/mg/3/00/4c003c66d3393.jpg"
    > Marvel.characters_in_comics(comic_ids: [30090, 162]) # ['Captain America','Captain Britain','Iron Man','Spider-Man','Thor']
    
An easy way to play with the gem without having to install it is to use the console. You need to have internet access as it will connect to the production Marvel API.

    $ ./bin/console
    > Marvel.set_config({public_key: 'foo', private_key: 'bar'})
    > Marvel.total_characters # 1485
    > Marvel.sample_character_thumbnail # "http://i.annihil.us/u/prod/marvel/i/mg/3/00/4c003c66d3393.jpg"
    > Marvel.characters_in_comics(comic_ids: [30090, 162]) # ['Captain America','Captain Britain','Iron Man','Spider-Man','Thor']

### Testing

To run the full test suite, do:

    $ rake

You don't need to be connected to the internet to test, as the responses from the Marvel API have been previously recorded. 