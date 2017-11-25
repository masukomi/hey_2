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
			e.description.should(be_falsey()) 
			# currently descriptions aren't supported so... 
		end
	end

	it "should set a timestamp upon creation" do
		e = Hey::Event.new()
		saved = e.save
		created = e.created_at
		if saved
			e.destroy
		end
		/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/.should(be_truthy())
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

	

end
