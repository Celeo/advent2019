import strformat, strutils

#[
  points = ...
  for potential in points
      visible = 0
      for other in points
          if potetial is other
              skip
          slope = get_slope(potential, other)
          if points_on_line(potential, slope) > 1
              TODO
          visible ++
      echo {potential} can see {visible}
]#

let data = readFile("input.txt").strip().splitLines()
var points: seq[(int, int, bool)] = @[]
for x in 0..<data[0].len():
    for y in 0..<data.len():
        points.add((x, y, data[x][y] == '#'))
