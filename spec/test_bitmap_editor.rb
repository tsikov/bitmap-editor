require 'bitmap_editor'

# Helper functions
def create_file_with_contents(file_path, contents)
  File.open(file_path, "w") do |f|
    f.write contents
  end
end

def delete_file_if_exists(file_path)
  File.delete(file_path) if File.exist?(file_path)
end

describe BitmapEditor do
  describe "#run" do
    after(:each) do
      delete_file_if_exists "spec/testfile.txt"
    end

    it "Raises an error if no file or a wrong file is given." do
      expect {
        BitmapEditor.new.run nil
      }.to raise_error(NoFileError, "Please supply a file")
      expect {
        BitmapEditor.new.run "non-existing-file-with-commands"
      }.to raise_error(FileNotFoundError, "Please provide the correct file")
    end

    it "Raises an error if the canvas size is not specified initialy." do
      create_file_with_contents "spec/testfile.txt", "V 4 3 2 G\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(CanvasSizeNotSpecifiedError, "Commands must start with a canvas size command")
    end

    it "Raises an error if the canvas is initialized more than once" do
      create_file_with_contents "spec/testfile.txt", "I 2 4\nI 4 3\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(CanvasSizeAlreadySpecified, "Canvas size specified for the second time on line 2")
    end

    it "Raises an error if an unknown command is encountered." do
      create_file_with_contents "spec/testfile.txt", "I 2 4\nX 4 3"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(UnknownCommandError, "Unknown command X on line 2")
    end

    it "Doesn't rise an error if all commands are legal" do
      create_file_with_contents "spec/testfile.txt", "I 4 3"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.not_to raise_error
    end

    it "Raises an error if the user tries to draw outside the canvas" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nL 5 5 R\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(DrawingOutOfCanvasError, "Cannot draw at 5 5")

      create_file_with_contents "spec/testfile.txt", "I 2 4\nL 3 3 G\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(DrawingOutOfCanvasError, "Cannot draw at 3 3")
    end

    it "Allows drawing of single pixels" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nL 2 2 R\nS"
      output = <<~EOF
      OOOO
      OROO
      OOOO
      EOF
      expect {
        be = BitmapEditor.new
        be.run "spec/testfile.txt"
      }.to output(output).to_stdout
    end

    it "Raises an error when drawing a single pixel if only 1 argument is provided" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nL 1\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(CommandArgumentError, "Please supply all arguments for the L command on line 2")
    end

    it "Raises an error when drawing a single pixel when too many arguments are provided" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nL 1 2 3 4 G\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(CommandArgumentError, "You supplied too many arguments for the L command on line 2")
    end

    it "Raises an error if location is given as a float" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nL 1 2.2 G\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(CommandArgumentError, 'Arguments ["1", "2.2", "G"] don\'t match template [/^[[:digit:]]+$/, /^[[:digit:]]+$/, /^[[:upper:]]$/]')
    end

    it "Raises an error when drawing a single pixel if a colour is not provided" do
      # note the 4 instead of the capital letter
      create_file_with_contents "spec/testfile.txt", "I 4 3\nL 1 2 4\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(CommandArgumentError, 'Arguments ["1", "2", "4"] don\'t match template [/^[[:digit:]]+$/, /^[[:digit:]]+$/, /^[[:upper:]]$/]')
    end

    it "Allows drawing of vertical lines" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nV 1 2 3 G\nS"
      output = <<~EOF
      OOOO
      GOOO
      GOOO
      EOF
      expect {
        be = BitmapEditor.new
        be.run "spec/testfile.txt"
      }.to output(output).to_stdout
    end

    it "Raises an error when drawing vertical lines if only 3 arguments are provided" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nV 1 2 3\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(CommandArgumentError, "Please supply all arguments for the V command on line 2")
    end

    it "Raises an error when drawing vertical lines when too many arguments are provided" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nV 1 2 3 4 G\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(CommandArgumentError, "You supplied too many arguments for the V command on line 2")
    end

    it "Raises an error when drawing vertical lines if a colour is not provided" do
      # note the 4 instead of the capital letter
      create_file_with_contents "spec/testfile.txt", "I 4 3\nV 1 2 3 4\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(CommandArgumentError, 'Arguments ["1", "2", "3", "4"] don\'t match template [/^[[:digit:]]+$/, /^[[:digit:]]+$/, /^[[:digit:]]+$/, /^[[:upper:]]$/]')
    end

    it "Raises an error if the user tries to draw outside the canvas with a vertical line" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nV 1 2 5 R\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(DrawingOutOfCanvasError, "Cannot draw at 1 2 5")
    end

    it "Allows drawing of horizontal lines" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nH 1 2 3 G\nS"
      output = <<~EOF
      OOOO
      OOOO
      GGOO
      EOF
      expect {
        be = BitmapEditor.new
        be.run "spec/testfile.txt"
      }.to output(output).to_stdout
    end

    it "Raises an error when drawing horizontal lines if only 3 arguments are provided" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nH 1 2 3\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(CommandArgumentError, "Please supply all arguments for the H command on line 2")
    end

    it "Raises an error when drawing horizontal lines when too many arguments are provided" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nH 1 2 3 4 G\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(CommandArgumentError, "You supplied too many arguments for the H command on line 2")
    end

    it "Raises an error when drawing horizontal lines if a colour is not provided" do
      # note the 4 instead of the capital letter
      create_file_with_contents "spec/testfile.txt", "I 4 3\nH 1 2 3 4\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(CommandArgumentError, 'Arguments ["1", "2", "3", "4"] don\'t match template [/^[[:digit:]]+$/, /^[[:digit:]]+$/, /^[[:digit:]]+$/, /^[[:upper:]]$/]')
    end

    it "Raises an error if the user tries to draw outside of canvas with a horizontal line" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nH 1 2 5 R\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(DrawingOutOfCanvasError, "Cannot draw at 1 2 5")
    end

    it "Can clear the canvas after drawing" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nH 1 2 3 G\nC\nS"
      output = <<~EOF
      OOOO
      OOOO
      OOOO
      EOF
      expect {
        be = BitmapEditor.new
        be.run "spec/testfile.txt"
      }.to output(output).to_stdout
    end

    it "Raises an error for the clearing command when too many arguments are provided" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nH 1 2 3 G\nC bla bla\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(CommandArgumentError, "You supplied too many arguments for the C command on line 3")
    end

    it "Can draw canvas to STDOUT" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nS"
      output = <<~EOF
      OOOO
      OOOO
      OOOO
      EOF
      expect {
        be = BitmapEditor.new
        be.run "spec/testfile.txt"
      }.to output(output).to_stdout
    end

    it "Can draw multiple drawing commands" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nL 1 1 R\nV 2 2 3 G\nS"
      output = <<~EOF
      ROOO
      OGOO
      OGOO
      EOF
      expect {
        be = BitmapEditor.new
        be.run "spec/testfile.txt"
      }.to output(output).to_stdout
    end

    it "Can draw the Fill Command" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nF 1 1 B\nS"
      output = <<~EOF
      BBBB
      BBBB
      BBBB
      EOF
      expect {
        be = BitmapEditor.new
        be.run "spec/testfile.txt"
      }.to output(output).to_stdout
    end
  end
end

