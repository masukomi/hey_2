module SentenceOptions
  class Parser
    getter :commands
    getter :banner
    def initialize(@banner : String)
      @commands = Array(Command).new()
    end
    def add_command(command : Command)
      @commands << command
    end
    def parse(args)
      if args.size > 0
        first_arg = args.first
        @commands.each do | command | 
          if command.handles_command? first_arg
            return command.handle (args.size > 1 ? args[1..-1] : Array(String).new())
          end
        end
      else
        puts @banner
        @commands.each do | command |
          puts command.description
        end
      end
      return false
    end
  end
end


