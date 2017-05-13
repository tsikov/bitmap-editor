context "Canvas" do
  it "Raises an error if the canvas size command has illegal parameters." do
    # Only one parameter
    create_file_with_contents "spec/testfile.txt", "I 4\nS"
    expect {
      BitmapEditor.new.run "spec/testfile.txt"
    }.to raise_error(CanvasSizeArgumentError, "Specify width and height of canvas")
    delete_file_if_exists "spec/testfile.txt"

    # Non-number as a parameter
    create_file_with_contents "spec/testfile.txt", "I 4 X\nS"
    expect {
      BitmapEditor.new.run "spec/testfile.txt"
    }.to raise_error(CanvasSizeArgumentError, "Width and height cannot be non-numbers or less than 1")
    delete_file_if_exists "spec/testfile.txt"

    # Negative number
    expect {
      Canvas.new(-2, 2)
    }.to raise_error(CanvasSizeArgumentError, "Width and height cannot be non-numbers or less than 1")

    # Float/Double number as parameter
    expect {
      Canvas.new(2.3, 4)
    }.to raise_error(CanvasSizeArgumentError, "Width and height must be integers")

    # Canvas size too big
    expect {
      Canvas.new(251, 250)
    }.to raise_error(CanvasSizeArgumentError, "Width and height cannot be bigger than 250")
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
