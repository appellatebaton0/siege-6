-- Drawing Game for Siege 6
-- Baton0

hint_pane = {
    x=5, y=5, sx=32, sy=32,

    _draw=function(this)
        rect(this.x, this.y, this.x + this.sx, this.y + this.sy, 0)
    end
}
game_pane = {
    x=5, y=41, sx=82, sy=82,

    _draw=function(this)
        rect(this.x, this.y, this.x + this.sx, this.y + this.sy, 0)
    end
}
direct_pane = {
    x=41, y=5, sx=46, sy=32,

    _draw=function(this)
        rect(this.x, this.y, this.x + this.sx, this.y + this.sy, 0)
    end
}
option_pane = {
    x=91, y=5, sx=32, sy=118,

    _draw=function(this)
        rect(this.x, this.y, this.x + this.sx, this.y + this.sy, 0)
    end
}

o = 3

function _draw()
    cls(4)

    // ⬇️⬆️⬅️➡️ fo. future reference

    hint_pane:_draw()
    game_pane:_draw()
    direct_pane:_draw()
    option_pane:_draw()

    print("start", 98, 15, 0)
end