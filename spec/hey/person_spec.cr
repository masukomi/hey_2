require "../spec_helper"
describe Hey::Person do
	it "should be initializable with id and name"  do
		p = Hey::Person.new(1, "bob")
		p.id.should(eq(1))
		p.name.should(eq("bob"))
	end

	it "should be initializable without an id" do
		p = Hey::Person.new(nil, "bob")
		p.should(be_truthy())
		p.name.should(eq("bob"))
	end

	it "should be able to load from the db" do
		p = Hey::Person.load(1)
		p.should(be_a(Hey::Person))
		p.id.should(eq(1))
		p.name.should(be_truthy()) #e.g. "Bob"
	end
end
