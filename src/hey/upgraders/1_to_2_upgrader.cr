require "sqlite3"
require "../config.cr"
require "file_utils"
config = Hey::Config.load
puts "I'll upgrade the db at: #{config.db_path}"
print "Is that ok? [y/n] "
ok = gets
if ok.to_s.downcase == "y"
  backup_at = "#{config.db_path}.bak"
  puts "backing it up at #{backup_at} first."
  FileUtils.cp(config.db_path.to_s, backup_at )

  DB.open "sqlite3://#{config.db_path}" do |db|


    db.exec("alter table events_tags rename to events_tags_orig")

    db.exec("CREATE TABLE 'events_tags' (
    'id'  INTEGER PRIMARY KEY AUTOINCREMENT,
    'event_id'  INTEGER NOT NULL,
    'tag_id'  INTEGER NOT NULL,
    FOREIGN KEY('tag_id') REFERENCES 'tags'('id'),
    FOREIGN KEY('event_id') REFERENCES 'events'('id')
    )")

    db.exec("insert into events_tags (tag_id, event_id) select tag_id, event_id 
    from events_tags_orig where events_tags_orig.event_id in (select id from events) 
    and events_tags_orig.tag_id in (select id from tags)")

    db.exec("drop table events_tags_orig")

    #-- people
    db.exec("alter table events_people rename to events_people_orig")

    db.exec("CREATE TABLE 'events_people' (
    'id'  INTEGER PRIMARY KEY AUTOINCREMENT,
    'event_id'  INTEGER NOT NULL,
    'person_id'  INTEGER NOT NULL,
    FOREIGN KEY('person_id') REFERENCES 'people'('id'),
    FOREIGN KEY('event_id') REFERENCES 'events'('id')
    )")

    db.exec("insert into events_people (person_id, event_id) select person_id,
    event_id from events_people_orig where events_people_orig.event_id in (select id from events) and
    events_people_orig.person_id in (select id from people)")

    db.exec("drop table events_people_orig")

    db.exec("CREATE TABLE 'versions' (
    'version'  TEXT NOT NULL UNIQUE
    )")
    db.exec("insert into versions (version) values ('2.0.0')")

  end
  puts "Data migration is complet. You're ready to go."
else
  puts "No worries. Thats' where hey will be looking for a DB though."
  puts "So, put a db there when you're ready."
end
