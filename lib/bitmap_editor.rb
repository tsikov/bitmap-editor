class NoFileError < StandardError; end
class FileNotFoundError < StandardError; end
class UnknownCommandError < StandardError; end
class CanvasSizeNotSpecifiedError < StandardError; end
class CanvasSizeAlreadySpecified < StandardError; end
class CanvasSizeParameterError < StandardError; end
class DrawCommandParameterError < StandardError; end

class Canvas
  attr_accessor :rows
  def initialize(width, height)
    # handles both strings and numbers
    #raise CanvasSizeParameterError, "Width must be an integer, float given" unless Float(width) % 1 == 0
    #raise CanvasSizeParameterError, "Height must be an integer, float given" unless Float(height) % 1 == 0
    unless [width, height].all? { |dim| dim.is_a?(Integer) }
      raise CanvasSizeParameterError, "Width and height must be integers"
    end
    if [width, height].any? { |dim| dim < 1 }
      raise CanvasSizeParameterError, "Width and height cannot be non-numbers or less than 1"
    end
    if [width, height].any? { |dim| dim > 250 }
      raise CanvasSizeParameterError, "Width and height cannot be bigger than 250"
    end
    @height = height
    @width = width
    @rows = Array.new(height) {
      Array.new(width, "O")
    }
  end

  def draw_pixel(column, row, colour)
    # FIXME: raise errors for bad arguments
    column = column.to_i - 1
    row = row.to_i - 1
    if column < 0 or row < 0 or column > @width or row > @height
      raise DrawCommandParameterError, "Cannot draw at #{column+1} #{row+1}"
    end
    @rows[row][column] = colour
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

    # First step: set the canvas
    first_line =  file.readline.chomp
    if command(first_line) != "I"
      raise CanvasSizeNotSpecifiedError, "Commands must start with a canvas size command"
    end

    # Canvas.new expects integers as parameters
    # FIXME: let's adopt the conventions that BE passes strings and Canvas tries to convert them, handle them, etc...
    canvas_dimentions = arguments(first_line).split.map(&:to_i)
    raise CanvasSizeParameterError, "Specify width and height of canvas" if canvas_dimentions.length != 2
    @canvas = Canvas.new(*canvas_dimentions)

    file.each_with_index do |line, line_number|
      command = command(line)
      line_number += 2 # we add 1 because we already too the first line, and another 1, because humans count from 1

      case command
      when 'I'
        raise CanvasSizeAlreadySpecified, "Canvas size specified for the second time on line #{line_number}"
      when 'L'
        arguments = arguments(line).split
        @canvas.draw_pixel(*arguments)
      when 'S'
      else
        raise UnknownCommandError, "Unknown command #{command} on line #{line_number}"
      end
    end
  end
end

