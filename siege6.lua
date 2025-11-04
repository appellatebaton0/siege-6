-- Drawing Game for Siege 6
-- Baton0

grid = {
    art = {},
    grid_size = 10,

    _init=function (this)
        this.canvas = {}

        for i=1,this.grid_size do
            row = {}
            for j=1,this.grid_size do
                row[j] = (i+j) % 2
            end
            this.canvas[i] = row
        end
    end
}

hint_pane = {
    x=5, y=5, sx=32, sy=32,

    _draw=function(this)
        rect(this.x, this.y, this.x + this.sx - 1, this.y + this.sy - 1, 0)

        canvas = grid.canvas
        for i=1,grid.grid_size do
            for j=1,grid.grid_size do
                left = (this.x + 1) + ((i-1) * 3)
                top = (this.y + 1) + ((j-1) * 3)
                right = (this.x + 1) + ((i) * 3) - 1
                bottom = (this.y + 1) + ((j) * 3) - 1

                rectfill(left, top, right, bottom, canvas[i][j])
            end
        end
    end
}
game_pane = {
    x=5, y=41, sx=82, sy=82,

    reset_canvas=function(this)
        this.canvas = {}

        for i=1,grid.grid_size do
            row = {}
            for j=1,grid.grid_size do
                row[j] = 7 // Make the grid white
            end
            this.canvas[i] = row
        end
    end,

    _init=function(this)
        this:reset_canvas()
    end,

    _draw=function(this)
        rect(this.x, this.y, this.x + this.sx - 1, this.y + this.sy - 1, 0)
    
        canvas = this.canvas
        for i=1,grid.grid_size do
            for j=1,grid.grid_size do
                left = (this.x + 1) + ((i-1) * 8)
                top = (this.y + 1) + ((j-1) * 8)
                right = (this.x + 1) + ((i) * 8) - 1
                bottom = (this.y + 1) + ((j) * 8) - 1

                rectfill(left, top, right, bottom, canvas[i][j])
            end
        end
    end
}
direct_pane = {
    x=41, y=5, sx=46, sy=32,

    _draw=function(this)
        rect(this.x, this.y, this.x + this.sx - 1, this.y + this.sy - 1, 0)
    end
}
option_pane = {
    x=91, y=5, sx=32, sy=118,

    _draw=function(this)
        rect(this.x, this.y, this.x + this.sx - 1, this.y + this.sy - 1, 0)
    end
}

function _init()
    grid:_init()
    game_pane:_init()
end

function _draw()
    cls(4)

    // ⬇️⬆️⬅️➡️ fo. future reference

    hint_pane:_draw()
    game_pane:_draw()
    direct_pane:_draw()
    option_pane:_draw()

    print("start", 98, 15, 0)
end