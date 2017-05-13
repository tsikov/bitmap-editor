class Canvas
  attr_accessor :rows
  def initialize(width, height)
    unless [width, height].all? { |dim| dim.is_a?(Integer) }
      raise CanvasSizeArgumentError, "Width and height must be integers"
    end
    if [width, height].any? { |dim| dim < 1 }
      raise CanvasSizeArgumentError, "Width and height cannot be non-numbers or less than 1"
    end
    if [width, height].any? { |dim| dim > 250 }
      raise CanvasSizeArgumentError, "Width and height cannot be bigger than 250"
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
    column = column.to_i
    row = row.to_i
    unless /[[:upper:]]/.match(colour)
      raise ColourNotProvidedError, "Colour must be a capital letter. #{colour} given"
    end
    if column < 1 or row < 1 or column > @width or row > @height
      raise DrawingOutOfCanvasError, "Cannot draw at #{column} #{row}"
    end
    @rows[row-1][column-1] = colour
  end

  def draw_horizontal_line(start_column, end_column, row, colour)
    start_column = start_column.to_i
    end_column = end_column.to_i
    row = row.to_i
    unless /[[:upper:]]/.match(colour)
      raise ColourNotProvidedError, "Colour must be a capital letter. #{colour} given"
    end
    if start_column < 1 or end_column < 1 or row < 1 or
        start_column > @width or end_column > @width or row > @height
      raise DrawingOutOfCanvasError, "Cannot draw at #{start_column} #{end_column} #{row}"
    end
    (start_column..end_column).each do |c|
      @rows[row-1][c-1] = colour
    end
  end

  def draw_vertical_line(column, start_row, end_row, colour)
    column = column.to_i
    start_row = start_row.to_i
    end_row = end_row.to_i
    unless /[[:upper:]]/.match(colour)
      raise ColourNotProvidedError, "Colour must be a capital letter. #{colour} given"
    end
    if column < 1 or start_row < 1 or end_row < 1 or
        column > @width or start_row > @height or end_row > @height
      raise DrawingOutOfCanvasError, "Cannot draw at #{column} #{start_row} #{end_row}"
    end
    (start_row..end_row).each do |r|
      @rows[r-1][column-1] = colour
    end
  end

  def clear
    initialize_canvas
  end

  def print
    @rows.each { |r| puts r.join }
  end
end
