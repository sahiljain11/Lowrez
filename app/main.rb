#require 'set'

#Sets sprite, label, and solid definitions and adds them to the appropriate collections.
def lowrez_tick args, lowrez_sprites, lowrez_labels, lowrez_borders, lowrez_solids, lowrez_mouse
    args.state.show_gridlines = false

    #Iterates through the images in the sprites folder.
    #lowrez_sprites << [0, 0, 64, 64, "sprites/explosion_#{0.frame_index 6, 4, true}.png"]

    #Creates labels of the alphabet in different positions and colors.
    #lowrez_labels << [0, 0,  "ABCDEFGHIJKLM", 255,   0,   0]
    #lowrez_labels << [0, 29, "ABCDEFGHIJKLM",   0, 255,   0]
    #lowrez_labels << [0, 60, "ABCDEFGHIJKLM",   0,   0, 255, 255]

    lowrez_solids << [0, 0, 64, 64, 255, 242, 232]

    args.state.frameNum ||= 0
    args.state.frameNum += 1
    args.state.time = args.state.frameNum / 60 #serves as t()

    #Circle Rings
    args.state.randCords ||= []
    args.state.numLines  ||= 25

    if args.state.randCords == []
        args.state.numLines.times do
            args.state.randCords << [rand(64), rand(64)]
        end
    end

    rand_lines(args, lowrez_solids)

    #draw_circle(32, 32, 3, 255, 0, 0, lowrez_solids)

    #for i in 0..2
    #  if (args.state.time * 2 / 3 % 3) >= i
    #    l = 53 - (i * 22)
    #    for a in 0..63
    #      b = a / 64
    #      
    #    end
    #  end
    #end

    #Creates a solid black background for the 64x64 canvas.
    #args.render_target(:lowrez).solids << [0, 0, 64, 64, 255, 255, 255]
end

def rand_lines args, lowrez_solids
    args.state.randCords.map do |cordArray|
        draw_line(cordArray[0], cordArray[1], cordArray[0] + 20, cordArray[1] + 10, 0, 0, 0, lowrez_solids)
    end
end

def draw_line x1, y1, x2, y2, r, g, b, lowrez_solids
    #Bresenham's Line Algorithm
    dx    = x2 - x1
    dy    = y2 - y1
    m_new = 2 * dy
    slope_error_new = m_new - dx
    y = y1
    for x in (x1 - 1)...(x2 + 1)
        slope_error_new += m_new
        if slope_error_new >= 0
            y += 1
            slope_error_new -= 2 * dx
        end
        lowrez_solids << [x, y, 1, 1, r, g, b]
    end
end

def draw_circle x, y, radius, r, g, b, lowrez_solids
    #allCords = Set[]
    #fill_circle(x, y, x, y, radius, r, g, b, lowrez_solids, allCords)
    #lowrez_solids << [positionX, positionY, 1, 1, r, g, b]
end

def fill_circle x, y, positionX, positionY, radius, r, g, b, lowrez_solids, allCords
    distance = ((positionX - x)**2 + (positionY - y)**2)**0.5
    if distance < radius || !(allCords === [positionX, positionY])
        #puts distance.to_s + " " + positionX.to_s + " " + positionY.to_s
        #allCords.add([positionX, positionY])
        #fill_circle(x, y, positionX + 1, positionY, radius, r, g, b, lowrez_solids)
        #fill_circle(x, y, positionX - 1, positionY, radius, r, 255, b, lowrez_solids)
        #fill_circle(x, y, positionX, positionY + 1, radius, r, g, b, lowrez_solids)
        #fill_circle(x, y, positionX, positionY - 1, radius, r, g, b, lowrez_solids)
    end
end

###################################################################################
# YOU CAN PLAY AROUND WITH THE CODE BELOW, BUT USE CAUTION AS THIS IS WHAT EMULATES
# THE 64x64 CANVAS.
###################################################################################

#Sets values for variables. These values are not changed, which is why ||= is not used.
TINY_RESOLUTION       = 64
TINY_SCALE            = 720.fdiv(TINY_RESOLUTION)
CENTER_OFFSET         = (1280 - 720).fdiv(2)
EMULATED_FONT_SIZE    = 20
EMULATED_FONT_X_ZERO  = 0
EMULATED_FONT_Y_ZERO  = 46

#Creates empty collections, and calls methods needed for the game to run properly.
def tick args
  sprites = []
  labels = []
  borders = []
  solids = []
  mouse = emulate_lowrez_mouse args
  args.state.show_gridlines = false
  lowrez_tick args, sprites, labels, borders, solids, mouse
  render_gridlines_if_needed args
  render_mouse_crosshairs args, mouse
  emulate_lowrez_scene args, sprites, labels, borders, solids, mouse
end

#Sets values based on the position of the mouse on the screen.
def emulate_lowrez_mouse args
  #Declares the mouse as a new entity and sets values for the x and y variables.
  args.state.new_entity_strict(:lowrez_mouse) do |m|
    m.x = args.mouse.x.idiv(TINY_SCALE) - CENTER_OFFSET.idiv(TINY_SCALE) - 1
    m.y = args.mouse.y.idiv(TINY_SCALE)

    #If the mouse is clicked, the click variable stores the mouse click's position.
    #Otherwise, the mouse is not considered to be clicked or down.
    if args.mouse.click
      m.click = [
        args.mouse.click.point.x.idiv(TINY_SCALE) - CENTER_OFFSET.idiv(TINY_SCALE) - 1,
        args.mouse.click.point.y.idiv(TINY_SCALE)
      ]
      m.down = m.click
    else
      m.click = nil
      m.down = nil
    end

    #If the mouse is up, the position of the mouse is stored in the up variable.
    #Otherwise, the mouse is not considered to be up.
    if args.mouse.up
      m.up = [
        args.mouse.up.point.x.idiv(TINY_SCALE) - CENTER_OFFSET.idiv(TINY_SCALE) - 1,
        args.mouse.up.point.y.idiv(TINY_SCALE)
      ]
    else
      m.up = nil
    end
  end
end

#Outputs the position of the mouse on the screen using a white label.
def render_mouse_crosshairs args, mouse
  return unless args.state.show_gridlines
  args.labels << [10, 25, "mouse: #{mouse.x} #{mouse.y}", 255, 255, 255]
end

#Emulates the low rez scene by adding solids, sprites, etc. to the appropriate collections and creating character labels.
def emulate_lowrez_scene args, sprites, labels, borders, solids, mouse
  args.render_target(:lowrez).solids  << [0, 0, 1280, 720]
  args.render_target(:lowrez).sprites << sprites
  args.render_target(:lowrez).borders << borders
  args.render_target(:lowrez).solids  << solids

  #The definition of a label is set, including the position, text, size, alignment, color, alpha, and font.
  #The font that is used is saved in the game's folder. Without the .ttf file, the label would not be created correctly.
  args.outputs.primitives << labels.map do |l|
    as_label = l.label
    l.text.each_char.each_with_index.map do |char, i|
      [CENTER_OFFSET + EMULATED_FONT_X_ZERO + (as_label.x * TINY_SCALE) + i * 5 * TINY_SCALE,
       EMULATED_FONT_Y_ZERO + (as_label.y * TINY_SCALE), char,
       EMULATED_FONT_SIZE, 0, as_label.r, as_label.g, as_label.b, as_label.a, 'dragonruby-gtk-4x4.ttf'].label
    end
  end

  #Uses arrays to set definitions, including the position and size, which are added to args.sprites and args.primitives.
  args.sprites    << [CENTER_OFFSET, 0, 1280 * TINY_SCALE, 720 * TINY_SCALE, :lowrez]
  args.primitives << [0, 0, CENTER_OFFSET, 720].solid
  args.primitives << [1280 - CENTER_OFFSET, 0, CENTER_OFFSET, 720].solid
  args.primitives << [0, 0, 1280, 2].solid
end

#If show_gridlines is true and the static_lines collection is empty, adds gridlines to the collection.
#Sets the position and color (gray) of each line.
#Otherwise, if show_gridlines is not true, the static_lines collection is cleared and made empty.
def render_gridlines_if_needed args
  if args.state.show_gridlines && args.static_lines.length == 0
    args.static_lines << 65.times.map do |i|
      [
        [CENTER_OFFSET + i * TINY_SCALE + 1,  0,
         CENTER_OFFSET + i * TINY_SCALE + 1,  720,                128, 128, 128],
        [CENTER_OFFSET + i * TINY_SCALE,      0,
         CENTER_OFFSET + i * TINY_SCALE,      720,                128, 128, 128],
        [CENTER_OFFSET,                       0 + i * TINY_SCALE,
         CENTER_OFFSET + 720,                 0 + i * TINY_SCALE, 128, 128, 128],
        [CENTER_OFFSET,                       1 + i * TINY_SCALE,
         CENTER_OFFSET + 720,                 1 + i * TINY_SCALE, 128, 128, 128]
      ]
    end
  elsif !args.state.show_gridlines
    args.static_lines.clear
  end
end
