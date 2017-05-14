class NoFileError < StandardError; end
class FileNotFoundError < StandardError; end
class UnknownCommandError < StandardError; end
class CanvasSizeNotSpecifiedError < StandardError; end
class CanvasSizeAlreadySpecified < StandardError; end
class CanvasSizeArgumentError < StandardError; end
class DrawingOutOfCanvasError < StandardError; end
class CommandArgumentError < StandardError; end
