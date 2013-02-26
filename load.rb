require 'time'
require 'active_support/time'

class Record
  def initialize(ts, count, h)
    @ts = ts
    @count = count
    @hist = h
  end

  attr_reader :ts, :count, :hist
end

class Builder
  def initialize filepath
    @path = filepath
  end

  def build
    File.open(@path, "r"){|fp|
      buckets = []
      bucket = Bucket.new(nil, lazy = true)
      while line = fp.gets
        ts, type, mac, signal, noise, seq, *add = line.split(/\t/)
        next unless type == "0x04"
        ts = Time.parse(ts)
        unless bucket.addable?(ts)
          buckets << bucket
          bucket = Bucket.new(ts)
        end
        bucket.add(ts, mac, signal.to_i)
      end
      buckets << bucket
      records = buckets.map{|bucket|
        bucket.to_record
      }
      return records
    }
  end
end

class MacVendor
  def initialize
    @ouihash = {}
    File.open("#{File.dirname(__FILE__)}/oui-list.txt"){|f|
      while line = f.gets
        oui, corp = line.split(/\t/)
        @ouihash[oui] = corp.chomp
      end
    }
  end

  def lookup(oui)
    oui = @ouihash[oui.gsub(":", "-").upcase]
    oui ? oui : "Unknown Vendor"
  end
end

class Bucket
  @@vendor = MacVendor.new

  def initialize ts, lazy = false
    if lazy
      @ts = nil
    else
      @ts = ts
    end
    @arr = []
  end

  def addable? ts
    unless @ts
      @ts = ts
    end
    ts - @ts < 1.minute
  end

  def add ts, mac, signal
    @arr << [ts, mac, signal]
  end

  def to_record
    macs = shrink
    h = vendor_count(macs)
    Record.new(@ts, macs.size, h)
  end

  def shrink
    @arr.map{|ts, mac, signal| mac}.uniq
  end

  def vendor_count macs
    h = Hash.new(0)
    macs.each{|mac|
      v = @@vendor.lookup(mac[0...8]).split(/\s|\t|,|\./)[0]
      h[v] += 1
    }
    h
  end
end
