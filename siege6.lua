
o = 3

function _draw()
    cls(4)

    
    canvas_size = 10

    ox = 5 oy = 5 m = o
    rectfill(ox,oy, 2 + (m * canvas_size) + ox, 2 + (m * canvas_size) + oy, 3)
    rect(ox,oy, 2 + (m * canvas_size) + ox, 2 + (m * canvas_size) + oy, 0)

    ox = 5 oy = 1 + (m * canvas_size) + (2 * ox) m = 11 - m
    rectfill(ox,oy,2 + (m * canvas_size) + ox, 2 + (m * canvas_size) + oy,3)
    rect(ox,oy,2 + (m * canvas_size) + ox, 2 + (m * canvas_size) + oy, 0)
    

    rectfill(91, 5, 123, 123,3)
    rect(91, 5, 123, 123, 0)

    rectfill(41, 5, 87, 37,3)
    rect(41, 5, 87, 37, 0)
    
    // ⬇️⬆️⬅️➡️ fo. future reference


    print("start", 98, 15, 0)
end