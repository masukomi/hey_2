module SentenceOptions
  class Parser
    getter :commands
    def initialize()
      @commands = Array(Command).new()
    end
    def add_command(command : Command)
      @commands << command
    end
    def parse(args)
      first_arg = args.first
      @commands.each do | command | 
        if command.handles_command? first_arg
          return command.handle (args.size > 1 ? args[0..-1] : Array(String).new())
        end
      end
      return false
    end
  end
end


