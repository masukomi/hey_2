require "../spec_helper"
include Hey
describe Hey::Person do
  it "should not allow you to set an id in initialization" do
    # a) no need
    # b) Granite won't let you
    p = Hey::Person.new(id: 1, name: "bob")
    p.id.should(be_falsey)
    p.name.should(eq("bob"))
  end

  it "should know its table name" do
    # this is testing a hack to the Granite ORM because
    # apparently that wasn't a thing
    Hey::Person.table_name.should(eq("people"))
  end

  it "should be initializable without an id" do
    p = Hey::Person.new(name: "bob")
    p.should(be_truthy())
    p.name.should(eq("bob"))
  end

  it "should be able to load from the db" do
    p = Hey::Person.find(1)
    p.should(be_a(Hey::Person))
    if !p.nil?
      p.id.should(eq(1))
      p.name.should(be_truthy()) # e.g. "Bob"
    end
  end
  describe "#find_or_create_with" do
    it "should not create dupes" do
      existing = Person.all
      existing_names = existing.map { |p| p.name }.compact
      (existing_names.size > 0).should(be_true())
      current_number = Person.count
      newish_people = Person.find_or_create_with(existing_names)
      newish_people.size.should(eq(current_number))
    end
    it "should only create needed" do
      existing = Person.all
      existing_names = existing.map { |p| p.name }.compact
      (existing_names.size > 0).should(be_true())
      current_number = Person.count
      test_name = "tester-#{Random.new.next_int}"
      newish_people = Person.find_or_create_with(existing_names + [test_name])
      newish_people.size.should(eq(current_number + 1))
      newish_people.map { |x| x.name }.includes?(test_name).should(be_true())
    end

    it "should only return supplied folks" do
      test_name = "tester-#{Random.new.next_int}"
      newish_people = Person.find_or_create_with([test_name])
      newish_people.size.should(eq(1))
      newish_people.map { |x| x.name }.includes?(test_name).should(be_true())
    end
  end
  describe "#find_or_create_from" do
    it "should return people with names matching space separated string" do
      names = "foo bar baz"
      people = Person.find_or_create_from(names)
      people.map{|p|p.name.to_s}.sort.should(eq(["bar", "baz", "foo"]))
    end
    it "should return people with names matching space separated string" do
      names = "foo, bar, baz"
      people = Person.find_or_create_from(names)
      people.map{|p|p.name.to_s}.sort.should(eq(["bar", "baz", "foo"]))
    end
    it "shouldn't have problems with empty strings" do
      names = "foo, ,  bar,, baz,"
      people = Person.find_or_create_from(names)
      people.map{|p|p.name.to_s}.sort.should(eq(["bar", "baz", "foo"]))
    end
  end

  it "should have associated EventPerson objects" do
    p = Hey::Person.find(1)
    if !p.nil?
      (p.event_persons.size > 0).should(be_true())
    end
  end

  it "should have associated events through EventPerson" do
    p = Hey::Person.find(1)
    if !p.nil?
      (p.event_persons.size > 0).should(be_true())
      (p.events.size > 0).should(be_true())
    end
  end
  it "should have associated events" do
    p = Hey::Person.find(1)
    if !p.nil?
      e = p.events
      e.size.should(be_truthy())
    else
      fail("expected person to have events")
    end
  end
end
