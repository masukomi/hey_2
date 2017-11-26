module SentenceOptions
  class Command
    getter :name, :description

    def initialize(
      @name        : String,
      @description : String,
      @handler     : Proc(Array(String), Bool)
    )

    end

    def handles_command?(a_command : String)
      return @name == a_command
    end

    def handle(args) : Bool
      @handler.call(args)
    end
  end
end
