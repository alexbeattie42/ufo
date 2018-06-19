module Ufo
  class TemplateScope
    extend Memoist

    attr_reader :helper
    attr_reader :task_definition_name
    def initialize(helper=nil, task_definition_name=nil)
      @helper = helper
      @task_definition_name = task_definition_name # only available from task_definition
        # not available from params
      load_variables_file("base")
      load_variables_file(Ufo.env)
    end

    # Load the variables defined in ufo/variables/* to make available in the
    # template blocks in ufo/templates/*.
    #
    # Example:
    #
    #   `ufo/variables/base.rb`:
    #     @name = "docker-process-name"
    #     @image = "docker-image-name"
    #
    #   `ufo/templates/main.json.erb`:
    #   {
    #     "containerDefinitions": [
    #       {
    #          "name": "<%= @name %>",
    #          "image": "<%= @image %>",
    #      ....
    #   }
    #
    # NOTE: Only able to make instance variables avaialble with instance_eval
    #   Wasnt able to make local variables available.
    def load_variables_file(filename)
      path = "#{Ufo.root}/.ufo/variables/#{filename}.rb"
      instance_eval(IO.read(path), path) if File.exist?(path)
    end

    # Add additional instance variables to template_scope
    def assign_instance_variables(vars)
      vars.each do |k,v|
        instance_variable_set("@#{k}".to_sym, v)
      end
    end

    def network
      Ufo::Setting::Network.new.data
    end
    memoize :network

    def settings
      Ufo.settings
    end

    def dynamic_name?
      x = ENV['DYNAMIC_NAME'] || @dynamic_name || settings["dynamic_name"]
      puts "ENV['DYNAMIC_NAME'] #{ENV['DYNAMIC_NAME'].inspect}"
      puts "x #{x.inspect}"
      puts "@dynamic_name #{@dynamic_name.inspect}"
      puts "settings[\"dynamic_name\"] #{settings["dynamic_name"].inspect}"
      x
    end
  end
end
