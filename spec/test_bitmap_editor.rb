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
    it "Raises an error if no file or a wrong file is given." do
      expect {
        BitmapEditor.new.run nil
      }.to raise_error(NoFileError, "Please supply a file")
      expect {
        BitmapEditor.new.run "non-existing-file-with-commands"
      }.to raise_error(FileNotFoundError, "Please provide the correct file")
    end

    it "Raises an error if the canvas size is not specified initialy." do
      create_file_with_contents "spec/testfile.txt", "V 4 3 2\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(CanvasSizeNotSpecifiedError, "Commands must start with a canvas size command")
      delete_file_if_exists "spec/testfile.txt"
    end

    it "Raises an error if the canvas is initialized more than once" do
      create_file_with_contents "spec/testfile.txt", "I 2 4\nI 4 3\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(CanvasSizeAlreadySpecified, "Canvas size specified for the second time on line 2")
      delete_file_if_exists "spec/testfile.txt"
    end

    it "Raises an error if unknown command is encountered." do
      create_file_with_contents "spec/testfile.txt", "I 2 4\nX 4 3"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(UnknownCommandError, "Unknown command X on line 2")
      delete_file_if_exists "spec/testfile.txt"
    end

    it "Doesn't rise an error if all commands are legal" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.not_to raise_error
      delete_file_if_exists "spec/testfile.txt"
    end

    it "Raises an error if the user tries to draw outside of canvas" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nL 5 5 R\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(DrawCommandParameterError, "Cannot draw at 5 5")
      delete_file_if_exists "spec/testfile.txt"
    end

    it "Allows drawing of single pixels" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nL 2 2 R\nS"
      be = BitmapEditor.new
      be.run "spec/testfile.txt"
      expect(be.canvas.rows[1][1]).to eq("R")
      delete_file_if_exists "spec/testfile.txt"
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
      delete_file_if_exists "spec/testfile.txt"
    end
  end

  context "Canvas" do
    it "Raises an error if the canvas size command has illegal parameters." do
      # Only one parameter
      create_file_with_contents "spec/testfile.txt", "I 4\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(CanvasSizeParameterError, "Specify width and height of canvas")
      delete_file_if_exists "spec/testfile.txt"

      # Non-number as a parameter
      create_file_with_contents "spec/testfile.txt", "I 4 X\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(CanvasSizeParameterError, "Width and height cannot be non-numbers or less than 1")
      delete_file_if_exists "spec/testfile.txt"

      # Negative number
      expect {
        Canvas.new(-2, 2)
      }.to raise_error(CanvasSizeParameterError, "Width and height cannot be non-numbers or less than 1")

      # Float/Double number as parameter
      expect {
        Canvas.new(2.3, 4)
      }.to raise_error(CanvasSizeParameterError, "Width and height must be integers")

      # Canvas size too big
      expect {
        Canvas.new(251, 250)
      }.to raise_error(CanvasSizeParameterError, "Width and height cannot be bigger than 250")
    end

    context "#pixel_at" do
      it "should give us the pixel at column, row" do
        canvas = Canvas.new(3, 2)
        canvas.rows = [[0, 1, 2], [3, 4, 5]]
        expect(canvas.pixel_at(1, 2)).to eq(3)
      end
    end

    context "#draw_pixel" do
      it "should draw pixels" do
        canvas = Canvas.new(4, 3)
        canvas.draw_pixel(1, 2, "B")
        expect(canvas.pixel_at(1, 2)).to eq("B")
      end
    end

    it "Should create itself on initialization with the right dimentions" do
      canvas = Canvas.new(2, 3)
      expect(canvas.rows.length).to eq(3)    # height
      expect(canvas.rows[0].length).to eq(2) # width
    end

    it "Should be white by default" do
      canvas = Canvas.new(2, 2)
      expect(canvas.rows.flatten.all? { |pixel| pixel == 'O' }).to be true
    end
  end
end
