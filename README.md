# Automatic Greeter 3000
### Because everyone is welcome

```ruby
next_meetup = Event.new('february-meetup-2014')

attendees = next_meetup.attendees.select do |attendee|
  attendee.events.one? && attendee.events.first == next_meetup
end

attendees.each(&:greet)
```

## What's this all about?
This is a program that greets all the newcomers to the [RUG::B](http://berlin.onruby.de).

### How to run?

``bundle && ruby newcomers.rb``
