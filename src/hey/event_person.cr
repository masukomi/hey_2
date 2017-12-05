require "granite_orm/adapter/sqlite"
require "../granite_orm/associations.cr"

module Hey
  class EventPerson < Granite::ORM::Base
    adapter sqlite
    table_name events_people
    field event_id : Int64
    field person_id : Int64
    owned_by Person # , column: person_id
    # ^^ gives us a .person method
    owned_by Event # , column: event_id
    # ^^ gives us a .event method
  end
end
