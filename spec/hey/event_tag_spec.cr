require "../spec_helper"
describe Hey::EventTag do
  it "should know its table name" do
    Hey::EventTag.table_name.should(eq("events_tags"))
  end
end
