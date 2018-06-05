require "readline"
class Hey::EventEditor
  include Hey::CliTool
  getter :event
  def initialize(@event : Event)

  end
  def interrogate!()
    puts @event.to_simple_string
    if edit_people?
      @event.persons = get_new_people()
      @event.save
    end
    if edit_tags?()
      @event.retag!(get_new_tags())
    end
    if edit_time?()
      @event.set_created_at!(get_new_time())
    end
    puts "Editing complete"
  end

  def edit_people?() : Bool
    ask_yes_no("change people?")
  end

  def edit_tags?() : Bool
    ask_yes_no("change tags?")
  end

  def edit_time?() : Bool
    ask_yes_no("change time?")
  end

  def get_new_time() : Time
    # read input
    input = ask_until_acceptable("what time did it happen ( HH:MM or H:MM)?",
                                 Proc(String, Bool).new { |arg|
                                   if arg.strip =~ /^([0-9]{1,2}):([0-9]{2})$/
                                     true
                                   else
                                     false
                                   end
                                 })
    begin
      new_time = string_to_time(input)
    rescue
      STDERR.puts "\"#{input}\" is not a valid time.
      please enter time as HH:MM or H:MM"
      get_new_time()
    end
    # validate input
  end

  def get_new_people() : Array(Hey::Person)
    input = ask_for_non_optional_input("What's the correct list of people? ")
    Hey::Person.find_or_create_from(input)
  end
  def get_new_tags() : Array(Hey::Tag)
    input = ask_for_non_optional_input("What's the correct list of tags? ")
    Hey::Tag.find_or_create_from(input)
  end
  def string_to_time(string : String) : Time
    # maintain the day in case they're editing a past
    # day's event time
    original_time = @event.get_created_at_time.as(Time)
    # we're editing an existing event. it MUST have a created_at
    m = string.match(/^([0-9]{1,2}):([0-9]{2})$/)
    raise "Invalid time string: #{string}" if m.nil?

    matcher = m.as(Regex::MatchData)
    Time.new(original_time.year,
             original_time.month,
             original_time.day,
             matcher[1].to_i,
             matcher[2].to_i,
             0)
  end
end
