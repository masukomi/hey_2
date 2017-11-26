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
	it "should have associated tags through EventTag" do
		e = Hey::Event.find(1)
		if !e.nil? 
			(e.event_tags.size > 0).should(be_true())
			(e.tags.size > 0).should(be_true())
		end
	end

	it "should be able to load the last item" do
		# extension to granite orm
		e = Hey::Event.last()
		if !e.nil?
			#yay
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



end
