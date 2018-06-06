require "../spec_helper"
describe Hey::EventEditor do
  # can't test anything else
  # because it all requires user input :/

  describe "#acceptable_time_proc" do
    it "should allow leading and trailing spaces" do
      e = Hey::Event.new
      ee = Hey::EventEditor.new(e)
      p = ee.acceptable_time_proc()
      p.call(" 11:22 ").should(eq(true))
    end
    it "should not allow > 2 digit hour" do
      e = Hey::Event.new
      ee = Hey::EventEditor.new(e)
      p = ee.acceptable_time_proc()
      p.call("111:22").should(eq(false))
    end
    it "should not allow > 2 digit minute" do
      e = Hey::Event.new
      ee = Hey::EventEditor.new(e)
      p = ee.acceptable_time_proc()
      p.call("11:222").should(eq(false))
    end
    it "should not allow 1 digit minute" do
      e = Hey::Event.new
      ee = Hey::EventEditor.new(e)
      p = ee.acceptable_time_proc()
      p.call("11:2").should(eq(false))
    end
    it "should not allow > 24 hours" do
      e = Hey::Event.new
      ee = Hey::EventEditor.new(e)
      p = ee.acceptable_time_proc()
      p.call("25:00").should(eq(false))
    end
    it "should not allow > 59 minutes" do
      e = Hey::Event.new
      ee = Hey::EventEditor.new(e)
      p = ee.acceptable_time_proc()
      p.call("12:60").should(eq(false))
    end


  end
  describe "#string_to_time" do
    it "should convert HH:MM to a time" do
      e = Hey::Event.new
      e.set_created_at # Time.now
      orig_time = e.get_created_at_time.as(Time)
      ee = Hey::EventEditor.new(e)
      new_time = ee.string_to_time("12:34")
      new_time.hour.should(eq(12))
      new_time.minute.should(eq(34))
      new_time.second.should(eq(0))
    end
    it "should convert H:MM to a time" do
      e = Hey::Event.new
      e.set_created_at # Time.now
      orig_time = e.get_created_at_time.as(Time)
      ee = Hey::EventEditor.new(e)
      new_time = ee.string_to_time("1:34")
      new_time.hour.should(eq(1))
      new_time.minute.should(eq(34))
      new_time.second.should(eq(0))
    end
    it "should blow up on invalid strings" do
      e = Hey::Event.new
      e.set_created_at # Time.now
      orig_time = e.get_created_at_time.as(Time)
      ee = Hey::EventEditor.new(e)
      expect_raises(Exception) do
        new_time = ee.string_to_time("111:333")
      end
    end

    it "should maintain the original year, month, and day" do
      e = Hey::Event.new
      e.set_created_at # Time.now
      orig_time = e.get_created_at_time.as(Time)
      ee = Hey::EventEditor.new(e)
      new_time = ee.string_to_time("12:34")
      new_time.year.should(eq(orig_time.year))
      new_time.month.should(eq(orig_time.month))
      new_time.day.should(eq(orig_time.day))
    end
  end
end
