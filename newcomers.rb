require "logger"
require "nokogiri"
require "open-uri"

ENDPOINT = 'http://berlin.onruby.de'

class ThingWithIdAndUrl
  attr_reader :id

  def initialize(id)
    @id = id
  end

  def url
    "#{ENDPOINT}/#{self.class.name.downcase}s/#{id}"
  end

  def ==(other)
    (other.is_a?(self.class) && other.id == self.id) || super
  end
end

class Event < ThingWithIdAndUrl
  def attendees
    fetch unless defined?(@attendees)
    @attendees
  end

  def fetch
    puts "loading #{id} details..."
    return unless doc = Nokogiri::HTML(open(url).read)
    @attendees = doc.at_xpath('//div[3]/div/section/div[3]/ul').children.map do |li|
      attendee_id = li.at_xpath('a')['href'].split('/').last
      User.new(attendee_id)
    end
  end
end

class User < ThingWithIdAndUrl
  attr_reader :name, :badge

  def events
    fetch unless defined?(@events)
    @events
  end

  def fetch
    print "."
    return unless doc = Nokogiri::HTML(open(url).read)
    @events = doc.at_xpath('//*[@id="events_participated"]/ul').children.map do |li|
      event_id = li.at_xpath('a')['href'].split('/').last
      Event.new(event_id)
    end
    @name = doc.at_xpath('//div[3]/div/section/div[1]/h3').text
    badge = doc.at_xpath('//div[3]/div/section/div[1]/div[2]/span[1]')
    @badge = badge && badge.text
  end
end

next_meetup = Event.new('february-meetup-2014')

attendees = next_meetup.attendees.select do |attendee|
  attendee.events.one? && attendee.events.first == next_meetup
end

puts "\n-- Welcome to the RUG::B --"
attendees.each do |attendee|
  puts "- #{attendee.name} - #{attendee.badge}"
end
