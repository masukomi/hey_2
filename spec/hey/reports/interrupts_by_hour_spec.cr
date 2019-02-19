require "../../spec_helper"

describe Hey::Reports::InterruptsByHour do
  it "should fill in missing hours" do
    ibh = Hey::Reports::InterruptsByHour.new()
    hours = Array(String).new()
    counts = Array(Int32).new()
    
    adjusted_hours, adjusted_counts = ibh.fill_hours_and_counts(-1,3, 
                                                                  hours,
                                                                  counts)
    adjusted_hours.size.should(eq(3))
    adjusted_counts.size.should(eq(3))
    adjusted_hours[0].should(eq("00"))
    adjusted_hours[2].should(eq("02"))
    adjusted_counts[0].should(eq(0))
    adjusted_counts[2].should(eq(0))
  end
end


