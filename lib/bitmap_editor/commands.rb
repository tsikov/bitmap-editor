class Command
  def self.check_args(args, line_number)
    if args.length < args_number
      raise CommandArgumentError, "Please supply all arguments for the #{self.to_s[0]} command on line #{line_number}"
    elsif args.length > args_number
      raise CommandArgumentError, "You supplied too many arguments for the #{self.to_s[0]} command on line #{line_number}"
    end
    unless args_template.zip(args).all? { |re, arg| re.match(arg) }
      raise CommandArgumentError, "Arguments #{args} don't match template #{args_template}"
    end
  end
end

class LCommand < Command
  def self.args_number
    3
  end

  def self.args_template
    [/^[[:digit:]]+$/, /^[[:digit:]]+$/, /^[[:upper:]]$/]
  end

  def self.execute(canvas, arguments)
    canvas.draw_pixel(*arguments)
  end
end

class VCommand < Command
  def self.args_number
    4
  end

  def self.args_template
    [/^[[:digit:]]+$/, /^[[:digit:]]+$/, /^[[:digit:]]+$/, /^[[:upper:]]$/]
  end

  def self.execute(canvas, arguments)
    canvas.draw_vertical_line(*arguments)
  end
end

class HCommand < Command
  def self.args_number
    4
  end

  def self.args_template
    [/^[[:digit:]]+$/, /^[[:digit:]]+$/, /^[[:digit:]]+$/, /^[[:upper:]]$/]
  end

  def self.execute(canvas, arguments)
    canvas.draw_horizontal_line(*arguments)
  end
end

class CCommand < Command
  def self.args_number
    0
  end

  def self.args_template
    []
  end

  def self.execute(canvas, arguments)
    canvas.clear
  end
end

class SCommand < Command
  def self.args_number
    0
  end

  def self.args_template
    []
  end

  def self.execute(canvas, arguments)
    canvas.print
  end
end
