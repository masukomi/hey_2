require "../spec_helper"
describe Hey::Tag do

  it "should know its table name" do
    Hey::Tag.table_name.should(eq("tags"))
  end
  it "should be initializable with a name" do
    e = Hey::Tag.new(name: "described")
    e.should(be_a(Hey::Tag))
    e.name.should(eq("described"))
  end

  it "should be able to load from the db" do
    e = Hey::Tag.find(1)
    e.should(be_a(Hey::Tag))
    e.should(be_truthy())
  end
  it "should have a name" do
    e = Hey::Tag.find(1)
    if !e.nil?
      e.id.should(eq(1))
      e.name.should(be_truthy()) 
    end
  end

  it "should have associated EventPerson objects" do
    e = Hey::Tag.find(1)
    if !e.nil? 
      (e.event_tags.size > 0).should(be_true())
    end
  end

  it "should have associated people through EventPerson" do
    t = Hey::Tag.find(1)
    if !t.nil? 
      (t.event_tags.size > 0).should(be_true())
      (t.events.size > 0).should(be_true())
    end
  end

  it "should process instructions" do
    event = Hey::Event.find(2) # last
    if !event.nil?
      starter_tags = event.tags.map{|e| e.name}
      starter_tags.includes?("pi_tag").should(be_false())
      Hey::Tag.all("WHERE name = ?", ["pi_tag"]).size.should(eq(0))
      Hey::Tag.all("WHERE name = ?", ["pi_tag2"]).size.should(eq(0))
      Hey::Tag.process_instructions(["2", "pi_tag", "pi_tag_2"])

      event = Hey::Event.find(2)
      if !event.nil?
        end_tags = event.tags.map{|e| e.name}
        (end_tags & ["pi_tag", "pi_tag_2"]).size.should(eq(2))
      end
    end
  end
  it "find_or_create_with should not create dupes" do
    existing = Tag.all()
    existing_names = existing.map{|p|p.name}.compact
    (existing_names.size > 0).should(be_true())
    current_number = Tag.count()
    newish_tags = Tag.find_or_create_with(existing_names)
    newish_tags.size.should(eq(current_number))
  end
  it "find_or_create_with should only create needed" do
    existing = Tag.all()
    existing_names = existing.map{|p|p.name}.compact
    (existing_names.size > 0).should(be_true())
    current_number = Tag.count()
    test_name = "tag-#{Random.new.next_int}"
    newish_tags = Tag.find_or_create_with(existing_names + [test_name])
    newish_tags.size.should(eq(current_number + 1))
    newish_tags.map{|x|x.name}.includes?(test_name).should(be_true())
  end

  it "find_or_create_with should only return supplied folks" do
    test_name = "tag-#{Random.new.next_int}"
    newish_tags = Tag.find_or_create_with([test_name])
    newish_tags.size.should(eq(1))
    newish_tags.map{|x|x.name}.includes?(test_name).should(be_true())

  end
end
