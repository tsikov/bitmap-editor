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

    it "Raises an error if unknown command is encountered." do
      create_file_with_contents "spec/testfile.txt", "I 2 4\nX 4 3"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(UnknownCommandError, "Unknown command X on line 2")
      delete_file_if_exists "spec/testfile.txt"
    end

    xit "Doesn't rise an error if all commands are legal" do
      create_file_with_contents "spec/testfile.txt", "I 4 3\nS"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.not_to raise_error
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
      create_file_with_contents "spec/testfile.txt", "I -2 2"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(CanvasSizeParameterError, "Width and height cannot be non-numbers or less than 1")
      delete_file_if_exists "spec/testfile.txt"

      # Canvas size too big
      create_file_with_contents "spec/testfile.txt", "I 251 250"
      expect {
        BitmapEditor.new.run "spec/testfile.txt"
      }.to raise_error(CanvasSizeParameterError, "Width and height cannot be bigger than 250")
      delete_file_if_exists "spec/testfile.txt"
    end

    it "Should create itself on initialization with the right dimentions" do
      create_file_with_contents "spec/testfile.txt", "I 2 3"
      be = BitmapEditor.new
      be.run "spec/testfile.txt"
      expect(be.canvas.rows.length).to eq(3)    # height
      expect(be.canvas.rows[0].length).to eq(2) # width
      delete_file_if_exists "spec/testfile.txt"
    end

    it "Should be white by default" do
      create_file_with_contents "spec/testfile.txt", "I 2 2"
      be = BitmapEditor.new
      be.run "spec/testfile.txt"
      expect(be.canvas.rows.flatten.all? { |pixel| pixel == 'O' }).to be true
      delete_file_if_exists "spec/testfile.txt"
    end
  end
end
