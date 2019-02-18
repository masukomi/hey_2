require "sandstone/adapter/sqlite"


module Hey
  class EventTag < Sandstone::ORM::Base
    adapter sqlite
    table_name events_tags
    field event_id : Int64
    field tag_id : Int64
    owned_by Tag # , column: person_id
    # ^^ gives us a .person method
    owned_by Event # , column: event_id
    # ^^ gives us a .event method
  end
end
