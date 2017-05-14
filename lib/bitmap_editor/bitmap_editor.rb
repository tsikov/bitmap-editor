class Command
  def initialize(canvas)
    @canvas = canvas
  end

  def check_args(args, line_number)
    if args.length < args_number
      raise CommandArgumentError, "Please supply all arguments for the #{command_name} command on line #{line_number}"
    elsif args.length > args_number
      raise CommandArgumentError, "You supplied too many arguments for the #{command_name} command on line #{line_number}"
    end
  end
end

class LCommand < Command
  #ARGS_TEMPLATE = /^\d+ \d+ [[:upper:]]$/
  #ARGS_RANGES = [0..@canvas.row, 0..@canvas.width]
  def command_name
    "L"
  end

  def args_number
    3
  end

  def execute(arguments)
    @canvas.draw_pixel(*arguments)
  end
end

class BitmapEditor
  attr_accessor :canvas

  def command(line)
    line[0]
  end

  def arguments(line)
    line[2..-1]
  end

  def run(file_name)
    # Raising an error will give the user more information (the stacktrace)
    # which makes it preferable than simply printing out the error message.
    raise NoFileError, "Please supply a file" if file_name.nil?
    raise FileNotFoundError, "Please provide the correct file" unless File.exists?(file_name)

    # We can now safely open the file
    file = File.open(file_name, "r")

    # First step: initialize the canvas
    first_line =  file.readline.chomp
    if command(first_line) != "I"
      raise CanvasSizeNotSpecifiedError, "Commands must start with a canvas size command"
    end

    canvas_dimentions = arguments(first_line).split.map(&:to_i)
    raise CanvasSizeArgumentError, "Specify width and height of canvas" if canvas_dimentions.length != 2
    @canvas = Canvas.new(*canvas_dimentions)

    l_command = LCommand.new(@canvas)

    file.each_with_index do |line, line_number|
      command = command(line)
      # we add 1 because we already too the first line,
      # and another 1, because humans count from 1
      line_number += 2

      case command
      when 'I'
        raise CanvasSizeAlreadySpecified, "Canvas size specified for the second time on line #{line_number}"
      when 'L'
        arguments = arguments(line).split
        l_command.check_args(arguments, line_number)
        l_command.execute(arguments)
      when 'V'
        arguments = arguments(line).split
        if arguments.length != 4
          raise CommandArgumentError, "Please supply all arguments for the V command on line #{line_number}"
        end
        @canvas.draw_vertical_line(*arguments)
      when 'H'
        arguments = arguments(line).split
        if arguments.length != 4
          raise CommandArgumentError, "Please supply all arguments for the H command on line #{line_number}"
        end
        @canvas.draw_horizontal_line(*arguments)
      when 'C'
        @canvas.clear
      when 'S'
        @canvas.print
      else
        raise UnknownCommandError, "Unknown command #{command} on line #{line_number}"
      end
    end
  end
end

