require "../spec_helper"
describe Hey::Tag do
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

	

end
