# Handle ^C gracefully
Signal::INT.trap do
  exit 0
end
# END Handle ^C



config = Hey::Config.load
config.running_hey
require "./hey/*" # no it doesn't make sense to require after using
# but the other way around doesn't work because
# it doesn't have the db info before loading up
# Granite ORM subclasses.
require "sentence_options"
include Hey
# TODO: figure out where to put all these methods
# preferably break them down over multiple classes

# todo: that'll blow up if there isn't one
# puts "db_path: #{config.db_path}"
# puts "DATABASE_URL env: #{ENV["DATABASE_URL"]}"
# puts "==================================================================="

parser = SentenceOptions::Parser.new(
  "Usage: Unlike many command line tools, hey uses
       sentence-like commands to simplify interaction.

       Normally you'll just say \"hey <name>\" to
       record an interruption by that person.

       If you'd like to tag the kind of interruption
       at the same time you can either say
       \"hey <name> tag <tag>\"
       OR
       \"hey <name> + <tag>\"

       Tags are space separated.

       Once you've got stuff in your database, You
       can use these commands to work with it and
       report on it.\n")
parser.add_command(
  SentenceOptions::Command.new("list",
    Hey::Event.command_description,
    Hey::Event.command_proc(config)))
parser.add_command(
  SentenceOptions::Command.new("tag",
    Hey::Tag.command_description,
    Hey::Tag.command_proc(config)))
parser.add_command(
  SentenceOptions::Command.new("retag",
    Hey::Tag.retag_command_description,
    Hey::Tag.retag_command_proc(config)))
parser.add_command(
  SentenceOptions::Command.new("tags", # plural
    Hey::Tag.tags_command_description,
    Hey::Tag.tags_command_proc(config)))
parser.add_command(
  SentenceOptions::Command.new("report",
    Report.command_description,
    Report.command_proc(config)))
parser.add_command(
  SentenceOptions::Command.new("delete",
    Hey::Event.delete_command_description,
    Hey::Event.delete_command_proc(config)))
parser.add_command(
  SentenceOptions::Command.new("kill",
    Hey::Killer.kill_command_description,
    Hey::Killer.kill_command_proc(config)))




parser.add_command(
  SentenceOptions::Command.new("--version",
"  hey --version
    Outputs the current version number",
    Proc(Array(String), Bool).new { |args| puts "Hey! Version #{Hey::VERSION}"; true }))
# should be last.
parser.add_command(SentenceOptions::Command.new("--help",
"  hey --help
    Outputs this usage info",
                                                Proc(Array(String), Bool).new {|args| puts parser.usage; true }))

if !ENV.has_key? "IN_SPEC_TEST"
  if ARGV.size == 0
    STDERR.puts parser.usage
    exit 1
  end
  cleaned_args = ARGV.map{|a| a.sub(/,$/, "")}
  successfully_handled = parser.parse(cleaned_args)
  if (!successfully_handled) && cleaned_args.size > 0
    # they're trying to create an event with a person's name
    if ! Hey::Event.create_from_args(cleaned_args)
      exit 1 # STDERR has already been printed to
    end
  end

end

# def process_command(*args)
# 	if args.size > 0
# 		command = args.shift
# 		case command
# 		when "comment"
# 			comment(args[1], args[2..-1].join(" "))
# 		when "graph"
# 			graph(args[1..-1])
# 		else
# 			STDERR.puts("Unknown command #{command}")
# 		end
# 	else
# 		list_events()
# 	end
# end
