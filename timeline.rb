#! ruby
# coding: utf-8

require 'rubygems'
require 'twitter'
require 'yaml/store'

class TimeLine
  def initialize(yml = "timeline.yml")
    @timeline_yml = "tmp/#{yml}"
    Dir.mkdir("tmp") unless Dir.exists?("tmp")
  end

  def set_timeline
    begin
      timeline = Twitter.public_timeline
      tweets_file = YAML::Store.new(@timeline_yml)
      tweets_file.transaction do
        tweets_file["tweets"] = timeline 
      end

    rescue Twitter::Error::BadRequest => e
      puts e.class
      puts e.message
    end
  end

  def get_timeline
    if File.exist?(@timeline_yml)
      tweets = YAML::Store.new(@timeline_yml) 
      tweets.transaction do
        @timeline = tweets["tweets"]
      end
    else
      puts "No such file - #{@timeline_yml}"
    end
  end

  def auto_reload_timeline(time = 300)
    loop do
      set_timeline
      printf_for_timeline(get_timeline)
      sleep(time)
    end
  end

  def printf_for_timeline(timeline)
    puts ("----- " + Time.now.to_s + " -----")
    puts "Time_line (name : text)"
    timeline.map {|t| puts "#{t.user['name'].ljust(25, " ")} : #{t.text.gsub(/\n/," ")}" }
  end
end

if $0 == __FILE__
  TimeLine.new.auto_reload_timeline
end
