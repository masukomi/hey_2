module SentenceOptions
  class Parser
    def initialize()
      @commands = Array(Command).new()
    end
    def add_command(command : Command)
      @commands << command
    end
    def parse(args)
      command = args.first
      @commands.each do | command | 
        if @command.handles_command? command
          return @command.handle (args.size > 1 ? args[0..-1] : String[].new())
        end
      end
      return false
    end
  end
end


