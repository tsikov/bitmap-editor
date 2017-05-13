# Bitmap editor

Simple bitmap editor made as an exercise for demonstrating adherence to
good programming practices.

## Usage

### Commands

There are 6 supported commands:

I M N - Create a new M x N image with all pixels coloured white (O).
C - Clears the table, setting all pixels to white (O).
L X Y C - Colours the pixel (X,Y) with colour C.
V X Y1 Y2 C - Draw a vertical segment of colour C in column X between rows Y1 and Y2 (inclusive).
H X1 X2 Y C - Draw a horizontal segment of colour C in row Y between columns X1 and X2 (inclusive).
S - Show the contents of the current image

### Example

To run the application you must supply a command file like so `bin/bitmap_editor examples/show.txt`

Input File:

```
I 5 6
L 1 3 A
V 2 3 6 W
H 3 5 2 Z
S
```

Expected Output:

```
OOOOO
OOZZZ
AWOOO
OWOOO
OWOOO
OWOOO
```

## Run tests

`>rspec`

## Running

`>bin/bitmap_editor examples/show.txt`
