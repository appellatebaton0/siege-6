-- Drawing Game for Siege 6
-- Baton0

// Helper Functions

function rectline(x, y, sx, sy, fill, outline)
    rectfill(x, y, x + sx, y + sy, fill)
    rect(x, y, x + sx, y + sy, outline)
end

function rectbord(x0, y0, x1, y1, fill, outline)
    rectfill(x0, y0, x1, y1, fill)
    rect(x0, y0, x1, y1, outline)
end

function move_towards(from, to, delta)
    amount = to - from

    // Make sure you dont move more than allowed by delta.
    if amount < 0 then amount = max(-delta, amount)
elseif amount > 0 then amount = min( delta, amount) end

    return from + amount
end

// Anything relating to the current time and state of the game.
state = {

    draw_time = 0.0,

    // A table of all the time values for each level. Lookup table of the log function time = 30 - log10(i)
    time_table = {60,55,53,51,50,48,47,46,46,45,44,44,43,43,42,42,42,41,41,40,40,40,40,39,39,39,39,38,38,38,38,37,37,37,37,37,36,36,36,36,36,36,35,35,35,35,35,35,35,35,34,34,34,34,34,34,34,34,33,33,33,33,33,33,33,33,33,33,32,32,32,32,32,32,32,32,32,32,32,31,31,31,31,31,31,31,31,31,31,31,31,31,30,30,30,30,30,30,30},

    _init=function (this)
        this.in_menu = true
        
        this.score = 0
        this.current_level = 1
    end,

    _update=function(this)
        if not this.in_menu then
            this.draw_time = move_towards(this.draw_time, 0, 1/30)
        end
    end,

    start_round=function(this, level)
        this.in_menu = false

        level = level or this.current_level
        this.current_level = level

        this.draw_time = this.time_table[level]

        grid:reset_canvas()
        game_pane:reset_canvas()

    end,

    attempt_win=function (this)

        // Return if not a win.
        for i=1,grid.grid_size do
            for j=1,grid.grid_size do
                if not (grid.canvas[i][j] == game_pane.canvas[i][j]) then return false end
            end
        end

        // Won round!

        // Add any spare time to the score
        this.score += flr(7 * this.draw_time)

        // Add the level value to the score
        this.score += flr(10 * this.current_level)

        this.current_level += 1
        this:start_round()
    end
}

// The space that holds the current art and runs everything relating to it.
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

}

// The space that tells the player what to draw
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

// The space in which the player draws.
game_pane = {
    x=5, y=41, sx=81, sy=81,

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

    draw_canvas=function(this)
        for i=1,grid.grid_size do
            for j=1,grid.grid_size do
                rectfill(
                    (this.x + 1) + ((i-1) * 8), 
                    (this.y + 1) + ((j-1) * 8), 
                    (this.x + 1) + ((i) * 8) - 1, 
                    (this.y + 1) + ((j) * 8) - 1,
                    this.canvas[i][j])
            end
        end
    end,

    _init=function(this)
        this:reset_canvas()
    end,

    _draw=function(this)
        rectline(this.x, this.y, this.sx, this.sy, 3, 0)

        if not state.in_menu then this:draw_canvas() end
    end
}

// The space that tells the player more information about what is going on.
direct_pane = {
    x=41, y=5, sx=45, sy=31,

    colors = {last = 0, current = 0, next = 0},
    update_colors=function (this)
        this.colors.current = cursor.color
        this.colors.last = cursor.color - 1
        this.colors.next = cursor.color + 1

        if this.colors.next > 15 then this.colors.next = 0 end
        if this.colors.next < 0  then this.colors.next = 15 end

        if this.colors.last > 15 then this.colors.last = 0 end
        if this.colors.last < 0  then this.colors.last = 15 end
    end,

    display_colors=function (this)

        offset = {x=this.x, y=this.y + 19}

        xc = 6 if btn(5) then xc = 5 end 
        oc = 6 if btn(4) then oc = 5 end

        print("<- DRAW!", this.x + 3, this.y + 4, 0)

        print("🅾️", offset.x + 5,  offset.y - 4, 5)
        print("❎", offset.x + 35, offset.y - 4, 5)

        print("🅾️", offset.x + 5,  offset.y - oc + 1, 6)
        print("❎", offset.x + 35, offset.y - xc + 1, 6)

        // Display prev. cur. nex. colors.

        
        rectbord(offset.x,      offset.y - oc + 8, offset.x + 15, offset.y + 12, this.colors.last,    0)
        rectline(offset.x + 15, offset.y, 15, 12, this.colors.current, 0)
        rectbord(offset.x + 30, offset.y - xc + 8, offset.x + 45, offset.y + 12, this.colors.next,    0)
        //


        
        

        //rectline(this.x,      this.y + 23, 15, this.sy, this.colors.last, 0)
        //rectline(this.x + 15, this.y + 23, 29, this.sy, this.colors.current, 0)
        //rectline(this.x + 29, this.y + 23, 45, this.sy, this.colors.next, 0)
    end,

    _draw=function(this)
        rectline(this.x, this.y, this.sx, this.sy, 3, 0)
        this:display_colors()
    end
}

// The space that either gives more information or allows for customization.
option_pane = {
    x=91, y=5, sx=32, sy=118,

    menu_data = {
        options = {"start", "optns"},
        index = 1,
    },

    menu=function(this)

        // Controlling the menu index
        index = this.menu_data.index
        options = this.menu_data.options
        if btnp(2) or btnp(0) then index -= 1 end
        if btnp(3) or btnp(1) then index += 1 end

        // Clamp to the menu.
        if index > #options then index = 1
        elseif index < 1 then index = #options end

        this.menu_data.index = index

        

        // Selecting a menu item
        if btnp(5) then
            if options[index] == "start" then
                state:start_round()
            end
        end
        
    end,

    scoreboard=function ()
        
    end,

    draw_menu=function (this)
        print("-menu-", this.x + 5, this.y + 5, 0)
        for i=1,#this.menu_data.options do
            if i == this.menu_data.index then
                message = ">"..tostr(this.menu_data.options[i])
            else
                message = this.menu_data.options[i]
            end

            print(message, this.x + 5, this.y + 7 +  (10 * i), 0)
        end
    end,

    draw_scoreboard=function (this)
        
        print("time", this.x + 5, this.y + 6, 0)
        print(ceil(state.draw_time), this.x + 5, this.y + 15)

        print("level", this.x + 5, this.y + 27)
        print(state.current_level, this.x + 5, this.y + 36)

        print("score", this.x + 5, this.y + 48)
        print(state.score, this.x + 5, this.y + 57, 0)
    end,

    _update=function(this)
        if state.in_menu then this:menu() else this:scoreboard() end
    end,

    _draw=function(this)
        rectline(this.x, this.y, this.sx, this.sy, 3, 0)

        if state.in_menu then this:draw_menu() else this:draw_scoreboard() end
        
        
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
        
    end,

    cycle_color=function(this)
        if btnp(5) then this.color += 1 end
        if btnp(4) then this.color -= 1 end

        if this.color > 15 then this.color = 0 end
        if this.color < 0 then this.color = 15 end

        direct_pane:update_colors()
    end,

    write=function(this)
        // Ignore if writing to a fufilled square / already that color
        if game_pane.canvas[this.x][this.y] == grid.canvas[this.x][this.y] then return end
        if game_pane.canvas[this.x][this.y] == this.color then return end

        game_pane.canvas[this.x][this.y] = this.color

        // Check for success
        state:attempt_win()
    end,

    _update=function(this)
        if not state.in_menu then
            this:control()
            this:cycle_color()
            this:write()
        end
    end,

    _draw=function (this)
        if state.in_menu then return end

        // Draw the cursor to its target position.
        left = (game_pane.x + 1) + ((this.x-1) * 8) - 1
        top = (game_pane.y + 1) + ((this.y-1) * 8) - 1
        right = (game_pane.x + 1) + ((this.x) * 8)
        bottom = (game_pane.y + 1) + ((this.y) * 8)

        rect(left, top, right, bottom, this.color)
    end
}

function _init()
    // Initialize the panes and anything else.
    grid:_init()
    game_pane:_init()

    state:_init()

    direct_pane:update_colors()
end

function _update()
    cursor:_update()
    state:_update()
    option_pane:_update()
end

function _draw()
    cls(1)

    // ⬇️⬆️⬅️➡️ fo. future reference

    hint_pane:_draw()
    game_pane:_draw()
    direct_pane:_draw()
    option_pane:_draw()

    cursor:_draw()

    
end