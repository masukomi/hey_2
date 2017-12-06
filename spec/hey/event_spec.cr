require "../spec_helper"
describe Hey::Event do
  it "should be initializable with a description" do
    e = Hey::Event.new(description: "described")
    e.should(be_a(Hey::Event))
    e.description.should(eq("described"))
  end

  it "should be able to load from the db" do
    e = Hey::Event.find(1)
    e.should(be_a(Hey::Event))
    if !e.nil?
      e.id.should(eq(1))
      # e.description.should(be_falsey())
      # currently descriptions aren't supported so...
    end
  end

  it "should set a timestamp upon creation" do
    e = Hey::Event.new
    saved = e.save
    created = e.created_at
    if saved
      e.destroy
    end
    created.nil?.should(be_false())
    if created
      (created == "").should(be_false())
      # SQLite3::DATE_FORMAT
      /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/.match(created).should(be_truthy())
    end
  end
  it "should have associated EventPerson objects" do
    e = Hey::Event.find(1)
    if !e.nil?
      (e.event_persons.size > 0).should(be_true())
    end
  end

  it "should have associated people through EventPerson" do
    e = Hey::Event.find(1)
    if !e.nil?
      (e.event_persons.size > 0).should(be_true())
      (e.persons.size > 0).should(be_true())
    end
  end
  it "should have associated tags through EventTag" do
    e = Hey::Event.find(1)
    if !e.nil?
      (e.event_tags.size > 0).should(be_true())
      (e.tags.size > 0).should(be_true())
    end
  end

  it "should be able to load the last item" do
    # extension to granite orm
    e = Hey::Event.last
    if !e.nil?
      # yay
      e.id.should(eq(2))
    else
      fail("unable to find via last method")
    end
  end

  it "should be able to find_by_last_or_id with last keyword" do
    e = Hey::Event.find_by_last_or_id("last")
    if !e.nil?
      e.id.should(eq(2))
    else
      fail("unable to find event by last keyword")
    end
  end

  it "should be able to find_by_last_or_id with string id" do
    e = Hey::Event.find_by_last_or_id("2")
    if !e.nil?
      e.id.should(eq(2))
    else
      fail("unable to find event by string id")
    end
  end

  it "should blow up find_by_last_or_id with bs id" do
    expect_raises Exception do
      e = Hey::Event.find_by_last_or_id("bullshit")
    end
  end
  it "should know its table name" do
    Hey::Event.table_name.should(eq("events"))
  end
  it "should be able to specify tags directly" do
    # testing new functionality added to granit orm
    e = Hey::Event.find(1)
    if !e.nil?
      # sanity check
      e.event_tags.size.should(eq(2))
      tags = e.tags
      tags.size.should(eq(2))

      original_size = e.tags.size
      unsaved_tag_name = "unsaved tags=test_tag"
      saved_tag_name = e.tags.first.name
      new_tag = Hey::Tag.new(name: unsaved_tag_name)
      new_size = original_size + 1
      new_tags_arr = [new_tag, e.tags.first]
      e.tags = new_tags_arr
      e = Hey::Event.find(1) # reload it
      if !e.nil?
        updated_tags = e.tags
        updated_tags.size.should(eq(2))
        updated_tag_names = updated_tags.map { |x| x.name }.compact.sort
        new_tags_arr_names = new_tags_arr.map { |x| x.name }.compact.sort
        updated_tag_names.should(eq(new_tags_arr_names))
      end
    end
  end
  it "should tag last with strings" do
    initial_count = Hey::Event.count
    event = Hey::Event.new
    event.save

    Hey::Event.count.should(eq(initial_count + 1))
    event.persons = [Hey::Person.first].compact

    event = Hey::Event.last
    if event
      # TODO it's getting the wrong event despite finding
      # .last with ORDER BY created_at DESC LIMIT 1
      event.tags.should(eq(Array(Hey::Tag).new))

      Hey::Event.find_and_tag("last", ["alpha", "beta"])
      event = Hey::Event.last
      if event
        event.tags.size.should(eq(2))
      end
    end
  end
  it "should be able to create  from args" do
    e = Hey::Event.create_from_args(["mc_testerson", "+", "test"])
    e.nil?.should(be_false())
  end

  it "should have associated people when created from args" do
    e = Hey::Event.create_from_args(["mc_testerson", "+", "test"])
    if !e.nil?
      e.persons.map { |p| p.name }.includes?("mc_testerson").should(be_true())
    end
  end

  it "should have associated tags when created from args" do
    e = Hey::Event.create_from_args(["mc_testerson", "+", "test"])
    if !e.nil?
      e.tags.size.should(eq(1))
      e.tags.map { |p| p.name }.includes?("test").should(be_true())
    end
  end
end
