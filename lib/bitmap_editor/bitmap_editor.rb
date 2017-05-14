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

class VCommand < Command
  def command_name
    "V"
  end

  def args_number
    4
  end

  def execute(arguments)
    @canvas.draw_vertical_line(*arguments)
  end
end

class HCommand < Command
  def command_name
    "H"
  end

  def args_number
    4
  end

  def execute(arguments)
    @canvas.draw_horizontal_line(*arguments)
  end
end

class CCommand < Command
  def command_name
    "C"
  end

  def args_number
    0
  end

  def execute(arguments)
    @canvas.clear
  end
end

class SCommand < Command
  def command_name
    "S"
  end

  def args_number
    0
  end

  def execute(arguments)
    @canvas.print
  end
end

class BitmapEditor
  attr_accessor :canvas

  def command(line)
    line[0]
  end

  def arguments(line)
    line[2..-1].nil? ? [] : line[2..-1].split
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

    canvas_dimentions = arguments(first_line).map(&:to_i)
    raise CanvasSizeArgumentError, "Specify width and height of canvas" if canvas_dimentions.length != 2
    @canvas = Canvas.new(*canvas_dimentions)

    l_command = LCommand.new(@canvas)
    v_command = VCommand.new(@canvas)
    h_command = HCommand.new(@canvas)
    c_command = CCommand.new(@canvas)
    s_command = SCommand.new(@canvas)

    file.each_with_index do |line, line_number|
      command = command(line)
      # we add 1 because we already too the first line,
      # and another 1, because humans count from 1
      line_number += 2

      case command
      when 'I'
        raise CanvasSizeAlreadySpecified, "Canvas size specified for the second time on line #{line_number}"
      when 'L'
        arguments = arguments(line)
        l_command.check_args(arguments, line_number)
        l_command.execute(arguments)
      when 'V'
        arguments = arguments(line)
        v_command.check_args(arguments, line_number)
        v_command.execute(arguments)
      when 'H'
        arguments = arguments(line)
        h_command.check_args(arguments, line_number)
        h_command.execute(arguments)
      when 'C'
        arguments = arguments(line)
        c_command.check_args(arguments, line_number)
        c_command.execute(arguments)
      when 'S'
        arguments = arguments(line)
        s_command.check_args(arguments, line_number)
        s_command.execute(arguments)
      else
        raise UnknownCommandError, "Unknown command #{command} on line #{line_number}"
      end
    end
  end
end

