alter table events_tags rename to events_tags_orig;

CREATE TABLE `events_tags` (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`event_id`	INTEGER NOT NULL,
	`tag_id`	INTEGER NOT NULL,
	FOREIGN KEY(`tag_id`) REFERENCES `tags`(`id`),
	FOREIGN KEY(`event_id`) REFERENCES `events`(`id`)
);
insert into events_tags (tag_id, event_id) select tag_id, event_id 
from et_2 where et_2.event_id in (select id from events) 
and et_2.tag_id in (select id from tags);

drop table events_tags_orig;

-- people
alter table events_people rename to events_people_orig;

CREATE TABLE `events_people` (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`event_id`	INTEGER NOT NULL,
	`person_id`	INTEGER NOT NULL,
	FOREIGN KEY(`tag_id`) REFERENCES `people`(`id`),
	FOREIGN KEY(`event_id`) REFERENCES `events`(`id`)
);

insert into events_people (person_id, event_id) select person_id, event_id from et_2 where et_2.event_id in (select id from events) and et_2.person_id in (select id from people);

drop table events_people_orig;
