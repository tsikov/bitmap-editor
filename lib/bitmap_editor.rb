require 'pry'

class NoFileError < StandardError; end
class FileNotFoundError < StandardError; end
class UnknownCommandError < StandardError; end
class CanvasSizeNotSpecifiedError < StandardError; end
class CanvasSizeAlreadySpecified < StandardError; end
class CanvasSizeParameterError < StandardError; end
class DrawCommandParameterError < StandardError; end
class ColourNotProvidedError < StandardError; end
class CommandArgumentError < StandardError; end

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
    initialize_canvas
  end

  def initialize_canvas
    @rows = Array.new(@height) {
      Array.new(@width, "O")
    }
  end

  def pixel_at(column, row)
    @rows[row-1][column-1]
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

  def draw_horizontal_line(start_column, end_column, row, colour)
    start_column = start_column.to_i - 1
    end_column = end_column.to_i - 1
    row = row.to_i - 1
    unless /[[:upper:]]/.match(colour)
      raise ColourNotProvidedError, "Colour must be a capital letter. #{colour} given"
    end
    # FIXME: check for bad input
    (start_column..end_column).each do |c|
      @rows[row][c] = colour
    end
  end

  def draw_vertical_line(column, start_row, end_row, colour)
    column = column.to_i - 1
    start_row = start_row.to_i - 1
    end_row = end_row.to_i - 1
    # FIXME: check for bad input
    (start_row..end_row).each do |r|
      @rows[r][column] = colour
    end
  end

  def clear
    initialize_canvas
  end

  def print
    @rows.each { |r| puts r.join }
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
      when 'V'
        arguments = arguments(line).split
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

