require 'pry'

class Command
  def self.check_args(args, line_number)
    if args.length < args_number
      raise CommandArgumentError, "Please supply all arguments for the #{command_name} command on line #{line_number}"
    elsif args.length > args_number
      raise CommandArgumentError, "You supplied too many arguments for the #{command_name} command on line #{line_number}"
    end
  end
end

class LCommand < Command
  def self.command_name
    "L"
  end

  def self.args_number
    3
  end

  def self.execute(canvas, arguments)
    canvas.draw_pixel(*arguments)
  end
end

class VCommand < Command
  def self.command_name
    "V"
  end

  def self.args_number
    4
  end

  def self.execute(canvas, arguments)
    canvas.draw_vertical_line(*arguments)
  end
end

class HCommand < Command
  def self.command_name
    "H"
  end

  def self.args_number
    4
  end

  def self.execute(canvas, arguments)
    canvas.draw_horizontal_line(*arguments)
  end
end

class CCommand < Command
  def self.command_name
    "C"
  end

  def self.args_number
    0
  end

  def self.execute(canvas, arguments)
    canvas.clear
  end
end

class SCommand < Command
  def self.command_name
    "S"
  end

  def self.args_number
    0
  end

  def self.execute(canvas, arguments)
    canvas.print
  end
end

class BitmapEditor
  attr_accessor :canvas
  COMMANDS = ['L', 'V', 'H', 'C', 'S']

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

    file.each_with_index do |line, line_number|
      command = command(line)
      arguments = arguments(line)
      # we add 1 because we already too the first line,
      # and another 1, because humans count from 1
      line_number += 2

      if command == 'I'
        raise CanvasSizeAlreadySpecified, "Canvas size specified for the second time on line #{line_number}"
      elsif !COMMANDS.include?(command)
        raise UnknownCommandError, "Unknown command #{command} on line #{line_number}"
      end

      klass = Object.const_get("#{command}Command")
      klass.check_args(arguments, line_number)
      klass.execute(@canvas, arguments)
    end
  end
end

