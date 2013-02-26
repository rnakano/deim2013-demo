require 'sinatra'
require 'json'
require './load'
require 'thread'

class Time
  def to_js
    (self.to_i + 9 * 60 * 60) * 1000
  end
end

$lock = Mutex.new

$path = ARGV.shift
builder = Builder.new($path)
$records = builder.build

$records.each{|r|
  puts "#{r.ts} #{r.count}"
}

Thread.start {
  loop do
    timer = Time.now
    builder = Builder.new($path)
    build_time = Time.now - timer
    records = builder.build  
    $lock.synchronize do
      $records = records
    end
    puts "build_time: #{build_time}"
    if build_time < 10
      sleep 10 - build_time
    else
      sleep 0
    end
  end
}

get '/api/all' do
  content_type :json
  $lock.synchronize do
    JSON.dump($records.map{|r|
                [r.ts.to_js, r.count]
              })
  end
end

get '/api/latest' do
  content_type :json
  $lock.synchronize do
    r = $records.last
    JSON.dump([r.ts.to_js, r.count])
  end
end

get '/api/hist' do
  content_type :json
  $lock.synchronize do
    JSON.dump($records.last.hist)
  end
end
