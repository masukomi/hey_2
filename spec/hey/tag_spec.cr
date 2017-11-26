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

	it "should process instructions" do
		event = Hey::Event.find(2) # last
		if !event.nil?
			starter_tags = event.tags.map{|e| e.name}
			starter_tags.includes?("pi_tag").should(be_false())
			Hey::Tag.where(name: "pi_tag").count.should(eq(0))
			Hey::Tag.where(name: "pi_tag2").count.should(eq(0))
			Hey::Tag.process_instructions(["2", "pi_tag", "pi_tag_2"])
			
			event = Hey::Event.find(2)
			if !event.nil?
				end_tags = event.tags.map{|e| e.name}
				(end_tags & ["pi_tag", "pi_tag_2"]).size.should(eq(2))
			end
		end
	end

end
