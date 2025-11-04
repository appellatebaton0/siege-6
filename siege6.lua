
o = 1
function _draw()
    cls(4)

    if btnp(4) then o += 1 end
    if btnp(5) then o -= 1 end

    canvas_size = 10

    ox = 5 oy = 5 m = o
    rectfill(ox,oy, 2 + (m * canvas_size) + ox, 2 + (m * canvas_size) + oy, 3)
    rect(ox,oy, 2 + (m * canvas_size) + ox, 2 + (m * canvas_size) + oy, 0)

    ox = 5 oy = (m * canvas_size) + (2 * ox) m = 11 - m
    rectfill(ox,oy,2 + (m * canvas_size) + ox, 2 + (m * canvas_size) + oy,3)
    rect(ox,oy,2 + (m * canvas_size) + ox, 2 + (m * canvas_size) + oy, 0)

end