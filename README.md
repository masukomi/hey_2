(Official homepage at [interrupttracker.com](https://interrupttracker.com))
# Hey

"Hey! I've got a question."  
"Hey take a look at this."  
"Hey!"

## Sound familiar?  
Interested in tracking just how many times you're interrupted and by who? 

Well hey, maybe hey is the tool for you.

When someone walks up to you and starts talking, breaks your concentration with
yet another slack message, or diety forbid, actually calls your phone...just
type `hey <person's name>` on the command line.

That's it. Entries will be created in a SQLite database for the event, the
person, their association, and when it happened.

Want to start tracking _why_ people are interrupting you? After the interruption 
you can, optionally, list and tag the events, leave a note, 
or generate reports graphing all your past interruptions.

Track it for long enough and patterns are sure to emerge. Maybe you'll find 
that a little documentation could save you hours a week. Maybe you'll find that
one person that's devouring more time than anyone else and discuss a better way to
handle things.

## Installation

### Homebrew
```
brew tap masukomi/homebrew-apps
brew install hey
```

### Build from source
If you don't already have the Crystal Language
compiler, you will need to install that first. On macOS you can install it with
Homebrew via

```
brew install crystal-lang
```

Clone the repo, 
`cd` into it.
run `./build.sh`

## Usage

#### Record an event

`hey <names>` 

`<names>` is a space separated list of one or more
people's names. 

Note: all names are downcased in the database to save worrying about multiple
entries when you accidentally type "bob" one time and "Bob" the next.

#### Record an event and tag it at the same time
Most of the time you create an event as it happens, and you don't know what it's
going to be about yet, so you create it, then tag it later. But sometimes you
create it just _after_ it happened and you _do_ know what it was about.

`hey <names> + <tags>`

`<names>` is a space separated list of one or more
people's names.

`<tags>` is a space separated list of tags to associated with this event.

There are no "right" tags to use. Use things that are meaningful to you but note
that they must not contain any spaces.

#### Viewing recent events
`hey` `hey list` or `hey list 3`

Shows you the most recent interruptions. Defaults to 25.

```
Last 25 interruptions in chronological order...

 | ID  | When                | Who       | Tags               |
 | 105 | 2017-06-17 08:53:48 | Bob, Mary | meeting, scheduled |
 | 106 | 2017-06-17 08:53:55 | Bob       | question           |
 | 109 | 2017-06-28 11:35:05 | Sam       | task               |
```


#### Reporting on recent events

To see a list of available reports run `hey report`

By default Hey comes with 2 reports, but if you're a programmer it's pretty easy
to create your own (see below). These are the two reports I've found to be the
most useful, and the least chaotic. 

The reports explored in the first version of
Hey tended to produce graphs that looked more like modern art than actionable
information. I have faith in you though, and look forward to seeing pull
requests with the reports you come up with to extract useful insights from your
database.

```
$ hey report
Available reports:
* people_overview
	Generates a table with all the people you've
	  interacted with, their recent activity, and tags.
* interrupts_by_hour
	Generates a graph of interruptions by hour.
```

To run a report simply type `hey report <report name here>` For example: 
`hey report people_overview`


##### People Overview Report

This is useful for seeing who has been interrupting you recently and why. If you
see someone with a _lot_ of interruptions you may want to consider sitting down
with them and doing a brain-dump on whatever topics keep coming up. If lots of
people show up with a tag for a particular topic, then maybe it's time to put
together some documentation you can refer people to. 

Sometimes a lot of activity from someone is normal and needs no action. For
example, maybe you're helping them spin up on a new project they're unfamiliar
with.

Note that the "Recent Activity" column is a tiny graph of activity by day. If you
were being regularly asked questions by the same person throughout the past 14
days it might look like `▁▃▂.▇..▄▅▂▆.▁.` The dots are days without interruptions.

```
$ hey report people_overview
People, 14 days of activity, & tags
| Who     | Recent Activity | Tags                    |
| ------- | --------------- | ----------------------- |
| bob     | ܂܂܂܂܂܂܂܂܂܂▅܂܂܂܂ | request, question       |
| mary    | ܂܂܂܂܂܂▁▂܂܂܂܂܂܂܂ | question, request       |
| thomas  | ܂܂܂܂܂܂܂܂܂܂▅܂܂܂܂ | question, tl, request   |
| john    | ܂܂▂܂܂܂܂܂܂܂܂܂܂܂܂ | question                |
| cartman | ܂܂܂܂܂܂▃܂܂܂܂܂܂܂܂ | request                 |
```


##### Interrupts By Hour Report

The interrupts by hour report is useful for helping to plan your day. In my case
I should avoid meetings between 11 AM and 3 PM (1100-1500) because its the time
when I most need to be available. Conversely, if there's something I _really_
need to focus on without interruptions I should be sure to let people know I'm
unavailable during those hours.

```
$ hey report interrupts_by_hour
Interrupts By Hour:

                                          o
                                          |
                                 o     o  |
                                 |     |  |
                                 |     |  |     o
                           o     |     |  |  o  |
                           |     |     |  |  |  |
                           |     |     |  |  |  |
                           |  o  |     |  |  |  |
                           |  |  |     |  |  |  |
                           |  |  |     |  |  |  |
                           |  |  |     |  |  |  |
                           |  |  |     |  |  |  |
o  o  o  o  o  o  o  o  o  |  |  |  o  |  |  |  |  o  o  o
00 01 02 03 04 05 07 07 08 09 10 11 12 13 14 15 16 17 18 23
```

## Sharing your DB across multiple computers

Hey has no built in sync functionality, but it's pretty easy to achieve through
services like Dropbox.

By default your DB is stored at `~/.config/hey/hey.db` BUT you can move it to
your a synced Dropbox folder and tell Hey where to look by setting the 
`HEY_DB_PATH` environment variable to reflect the new location. Maybe 
`HEY_DB_PATH=$HOME/Dropbox/apps/hey/hey.db` (if that's where you put it).



## Development

### Writing Custom reports
Writing custom reports is pretty easy. You can write them in any language you
want. The only requirements are that your report needs to be an executable, and
it needs to be able to respond to respond to two sets of arguments:

```
your_report --info
# and 
your_report -d path/to/hey.db
```

The info request should write a JSON object to standard out. It must contain the
following keys and values:

```
name: the name of your report
      **This should not contain spaces** as it is what people 
      will use to tell Hey! to run your report
description: a description of your report
db_version: the minimum version of the 
            hey db you support (currently we're at "2.0")
```

Example Info:

```
{"name":"test_report","description":"just a test.","db_version":"2.0"}
```


When a user runs `hey report` a listing of all the reports will be output,
including the information you've provided in the `--info` json.

In this case you would say `hey report test_report` (because `test_report`
is it's name) to run that test report.

**The other request**, with a path to the database is what is called when
someone runs the report (`hey report test_report`) It can do whatever you want it to.
There are no restrictions. Hey will just call it and assume it does what it's
intended to do.

Once you've created your report just put it in this directory: 
`~/.config/hey/reports/` and Hey! will take care of the rest.

You can find the latest version of the database schema at
`starter_files/hey.db.sql`



## Contributing

1. Fork it ( https://github.com/[your-github-name]/hey/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

NOTE: due to a bug in (Shards 0.8.1 (2019-02-05)) which is distributed in 
Crystal v0.27.0 you will need to change the shards.yml to require 
sandstone via a local path.

## Contributors

- [[your-github-name]](https://github.com/[your-github-name]) masukomi - creator, maintainer
