require 'sinatra'
require 'json'
require './load'

class Time
  def to_js
    (self.to_i + 9 * 60 * 60) * 1000
  end
end

builder = Builder.new(ARGV.shift)
$records = builder.build

$records.each{|r|
  puts "#{r.ts} #{r.count}"
}

get '/api/all' do
  content_type :json
  JSON.dump($records.map{|r|
    [r.ts.to_js, r.count]
  })
end

get '/api/latest' do
  content_type :json
  r = $records.last
  JSON.dump([r.ts.to_js, r.count])
end

get '/api/hist' do
  content_type :json
  JSON.dump($records.last.hist)
end
