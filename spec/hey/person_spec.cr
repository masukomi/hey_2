require "../spec_helper"
describe Hey::Person do
	it "should not allow you to set an id in initialization"  do
		# a) no need
		# b) Granite won't let you
		puts "DATABASE_URL: #{ENV["DATABASE_URL"]}"
		p = Hey::Person.new(id: 1, name: "bob")
		p.id.should(be_falsey)
		p.name.should(eq("bob"))
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
			p.name.should(be_truthy()) #e.g. "Bob"
		end
	end
end
