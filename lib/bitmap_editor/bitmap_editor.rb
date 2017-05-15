class BitmapEditor
  NON_INITIALIZATION_COMMANDS = ['L', 'V', 'H', 'C', 'S']

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
    canvas_dimentions = arguments(first_line).map(&:to_i)
    if command(first_line) != "I"
      raise CanvasSizeNotSpecifiedError, "Commands must start with a canvas size command"
    elsif canvas_dimentions.length != 2
      raise CanvasSizeArgumentError, "Specify width and height of canvas"
    end
    canvas = Canvas.new(*canvas_dimentions)

    file.each_with_index do |line, line_number|
      command = command(line)
      arguments = arguments(line)
      # we add 1 because we already read the first line,
      # and another 1, because humans count from 1
      line_number += 2

      if command == 'I'
        raise CanvasSizeAlreadySpecified, "Canvas size specified for the second time on line #{line_number}"
      elsif !NON_INITIALIZATION_COMMANDS.include?(command)
        raise UnknownCommandError, "Unknown command #{command} on line #{line_number}"
      end

      klass = Object.const_get("#{command}Command")
      klass.check_args(arguments, line_number)
      klass.execute(canvas, arguments)
    end
  end
end

