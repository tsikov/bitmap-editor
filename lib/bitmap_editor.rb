require 'pry'

class NoFileError < StandardError; end
class FileNotFoundError < StandardError; end
class UnknownCommandError < StandardError; end
class CanvasSizeNotSpecifiedError < StandardError; end
class CanvasSizeParameterError < StandardError; end

class Canvas
  def initialize(rows, cols)
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

    # First step: set the canvas
    file = File.open(file_name)
    first_line =  file.readline.chomp
    if command(first_line) != "I"
      raise CanvasSizeNotSpecifiedError, "Commands must start with a canvas size command"
    end

    canvas_dimentions = arguments(first_line).split.map(&:to_i)
    raise CanvasSizeParameterError, "Specify width and height of canvas" if canvas_dimentions.length != 2

    # to_i converts characters to 0, so we don't need to check explicitly for that beforehand
    if canvas_dimentions.any? { |dim| dim == 0 }
      raise CanvasSizeParameterError, "Width and height cannot be non-numbers or 0"
    end

    @canvas = Canvas.new(*canvas_dimentions)

    File.open(file_name).each_with_index do |line, line_number|
      command = command(line)

      case command
      when 'I'
        puts "do nothing for now"
      when 'S'
          puts "There is no image"
      else
        raise UnknownCommandError, "Unknown command #{command} on line #{line_number+1}"
      end
    end
  end
end
