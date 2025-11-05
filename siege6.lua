-- Drawing Game for Siege 6
-- Baton0

grid = {
    art = {},
    grid_size = 10,

    reset_canvas=function(this)
        while true do
            next_index = flr(rnd(#this.canvas_options) + 1)

            if next_index != this.current_index then break end
        end

        this.canvas = {}

        for i=1,this.grid_size do
            row = {}
            for j=1,this.grid_size do
                row[j] = this.canvas_options[next_index][i][j]
            end
            this.canvas[i] = row
        end

        this.current_index = next_index
    end,

    _init=function (this)
        this.current_index = -1
        this:reset_canvas()
    end,

    canvas_options = {
        {
            {0,0,0,0,0,0,0,0,0,0},
            {0,3,6,6,6,6,6,6,6,0},
            {0,3,0,0,0,0,0,0,5,0},
            {0,3,0,0,0,0,0,0,5,0},
            {0,3,0,0,0,0,0,0,5,0},
            {0,3,0,0,0,0,0,0,5,0},
            {0,3,0,0,0,0,0,0,5,0},
            {0,3,0,0,0,0,0,0,5,0},
            {0,4,4,4,4,4,4,4,5,0},
            {0,0,0,0,0,0,0,0,0,0},
        },
        {
            {0,0,0,0,0,0,0,0,0,4},
            {3,6,6,6,6,6,6,6,0,5},
            {3,0,0,0,0,0,0,5,0,6},
            {3,0,0,0,0,0,0,5,0,5},
            {3,0,0,0,0,0,0,5,0,4},
            {3,0,0,0,0,0,0,5,0,5},
            {3,0,0,0,0,0,0,5,0,6},
            {3,0,0,0,0,0,0,5,0,5},
            {4,4,4,4,4,4,4,5,0,4},
            {0,0,0,0,0,0,0,0,0,3},
        }
    },

    // Check the grids against each other to see if its complete.
    attempt_win=function(this)

        // Return if not a win.
        for i=1,this.grid_size do
            for j=1,this.grid_size do
                if not (this.canvas[i][j] == game_pane.canvas[i][j]) then return false end
            end
        end

        // Won!

        this:reset_canvas()
        game_pane:reset_canvas()
        
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

cursor = {
    x=4, y=4,

    color = 1,
    
    control=function(this)
        nx = this.x ny = this.y

        // Control the next position
        if     btnp(0) then nx -= 1
        elseif btnp(1) then nx += 1
        elseif btnp(2) then ny -= 1
        elseif btnp(3) then ny += 1 
        else return end

        // Clamp the position onto the grid.
        if nx > grid.grid_size then nx = grid.grid_size end
        if nx < 1 then nx = 1 end
        if ny > grid.grid_size then ny = grid.grid_size end
        if ny < 1 then ny = 1 end

        // Apply
        this.x = nx this.y = ny

        grid:attempt_win()
    end,

    cycle_color=function(this)
        if btnp(4) then this.color += 1 end
        if this.color > 15 then this.color = 0 end
    end,

    write=function(this)
        // Ignore if writing to a fufilled square / already that color
        if game_pane.canvas[this.x][this.y] == grid.canvas[this.x][this.y] then return end
        if game_pane.canvas[this.x][this.y] == this.color then return end

        game_pane.canvas[this.x][this.y] = this.color

        // Check for success
        grid:attempt_win()
    end,

    _update=function(this)
        this:control()
        this:cycle_color()
        this:write()
    end,

    _draw=function (this)
        left = (game_pane.x + 1) + ((this.x-1) * 8) - 1
        top = (game_pane.y + 1) + ((this.y-1) * 8) - 1
        right = (game_pane.x + 1) + ((this.x) * 8)
        bottom = (game_pane.y + 1) + ((this.y) * 8)

        rect(left, top, right, bottom, this.color)

        rect(left, top, left, top, 15 - this.color)
        rect(right, top, right, top, 15 - this.color)
        rect(left, bottom, left, bottom, 15 - this.color)
        rect(right, bottom, right, bottom, 15 - this.color)
    end
}

function _init()
    grid:_init()
    game_pane:_init()
end

function _update()
    cursor:_update()
end

function _draw()
    cls(4)

    // ⬇️⬆️⬅️➡️ fo. future reference

    hint_pane:_draw()
    game_pane:_draw()
    direct_pane:_draw()
    option_pane:_draw()

    cursor:_draw()

    print("start", 98, 15, 0)
end