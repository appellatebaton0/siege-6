pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- pixel art panic
-- by baton0

code = {
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 
        'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 
        'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 
        'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 
        'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 
        'y', 'z', '!', '@', '#', '$', '%', '^', '&', '*',
        '(', ')', '[', ']', '{', '}', ':', ';', ',', '.',
        '<', '>', '/', '?', '~', '`', '-', '_', '+', '+' 
    }


//num_as_code=function(value)
//    if value <= 9 then return tostr(value) end
//    return code[value - 9]
//end

code_as_num=function(value)
    if tonum(value) != nil then
        if tonum(value) <= 9 then return tonum(value) end
    end

    inverse={}
    for k,v in pairs(code) do
        inverse[v]=k
    end

    return inverse[value] + 9
end

//encode=function(table)
//    // Encodes a table of color values 
//    grid_size = #table
//
//    // Get the table as a hex-like string.
//    hex = ''
//    for i=1,grid_size do
//        for j=1,grid_size do
//            hex = hex..num_as_code(table[j][i])
//        end
//    end
//
//    // Compress the string.
//
//    compress = ''
//    last = ''
//    last_value = 1
//    for i=1,#hex do
//            if last == '' then last = hex[i]
//        elseif last == hex[i] then last_value += 1
//        elseif last != hex[i] then 
//            compress = compress..last..num_as_code(last_value)
//            last = hex[i]
//            last_value = 1
//        end
//    end
//    compress = compress..last..num_as_code(last_value)
//
//    printh(compress..",", 'encoded.txt')
//
//    
//    return compress
//end

// Decodes an art string into a usable array
decode=function(string)

    response = {}

    for i=1,#string/2 do
        color = code_as_num(string[(i * 2) - 1])
        count = code_as_num(string[i * 2])

        for i=1,count do
            response[#response + 1] = color
        end
    end
    
    return response


end



// Options variables

outline_color = 0
background_color = 1
pane_color = 3
transition_color = 2
text_color = 0

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

function as_progress(value)
    return max(0,1 - (4 * abs((value - 0.5) * (value - 0.5))))
end

// Anything relating to the current time and state of the game.
state = {

    draw_time = 0.0,

    // A table of all the time values for each level. Lookup table of the log function time = 30 - log10(i)
    time_table = {60,55,53,51,50,48,47,46,46,45,44,44,43,43,42,42,42,41,41,40,40,40,40,39,39,39,39,38,38,38,38,37,37,37,37,37,36,36,36,36,36,36,35,35,35,35,35,35,35,35,34,34,34,34,34,34,34,34,33,33,33,33,33,33,33,33,33,33,32,32,32,32,32,32,32,32,32,32,32,31,31,31,31,31,31,31,31,31,31,31,31,31,30,30,30,30,30,30,30},

    _init=function (this)
        this.in_menu = true

        this.in_transition = false
        this.transistors_called = false
        this.transition_timer = 0.0
        
        this.score = 0
        this.highscore = 0
        this.current_level = 1
        this.highlevel = 0
    end,

    _update=function(this)
        if not this.in_menu then
            this.draw_time = move_towards(this.draw_time, 0, 1/30)

            if this.draw_time == 0 then
                this.in_menu = true

                
                if this.score > this.highscore then this.highscore = this.score end
                if this.current_level > this.highlevel then this.highlevel = this.current_level end

                sfx(1)
                state.transition_calls["game2lose"]=function()
                    menu_pane:change_menu("lose")
                    direct_pane:change_state("instructions")
                    game_pane:change_state("score")
                    hint_pane:change_state("icon")
                    
                end

                state:transition({menu_pane, game_pane, hint_pane, direct_pane})
            end
        end
        if this.in_transition then
            this.transition_timer = move_towards(this.transition_timer, 0, 1/30)

            if this.transition_timer <= 0.5 and not this.transistors_called then
                this:call_transition_calls()
                this.transistors_called = true
            end

            if this.transition_timer == 0.0 then
                
                this.in_transition = false
                
                for i, pane in pairs(this.transistors) do
                    pane.in_transition = false
                end

                this.transistors_called = false
            end
        end
    end,

    transition_calls = {},
    call_transition_calls=function (this)
        for i, funct in pairs(this.transition_calls) do
            funct()
        end

        this.transition_calls = {}
    end,
    transistors = {},
    transition=function(this, panes)
        this.in_transition = true
        this.transition_timer = 1.0

        for i, pane in pairs(panes) do
            pane.in_transition = true
            this.transistors[#this.transistors+1] = pane
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
                if not (grid.canvas[i + ((j - 1) * grid.grid_size)] == game_pane.canvas[i][j]) then return false end
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
    grid_size = 10,

    reset_canvas=function(this)
        while true do
            next_index = flr(rnd(#this.canvas_options) + 1)

            if next_index != this.current_index then break end
        end

        this.canvas = decode(this.canvas_options[next_index])



        //for i=1,this.grid_size do
        //    row = {}
        //    for j=1,this.grid_size do
        //        row[j] = this.canvas_options[next_index][i][j]
        //    end
        //    this.canvas[i] = row
        //end

        this.current_index = next_index
    end,

    _init=function (this)
        this.current_index = -1
        this:reset_canvas()
    end,

    // The compacted hex values of the art pieces.
    canvas_options = {
        "1B3819311236113112311431113112311131123111311231113411311231163112381B",
        "C772C172C873CM73C675CM73C477C5",
        "7Q627164726U526252625R",
        "7CD174D174D174D174D174D17ND176D173D67M",
        "75E178E1A1E178E178B27831782477227696744174917441744172",
        "F181F181F181F181F381F181F181F181F381F181F181F181F381F181F181F181F381F181F181F183F181F181F181F482F181F185F381F68AFA",
        "5G9156655571617162556454D151D454D311D454D211D151D154D456D152D153",
        "0DD103D105D505D1C1D1C1D1062307D30611D111D1110511D111D1110412D111D1120B",
    },

}

// The space that tells the player what to draw
hint_pane = {
    x=5, y=5, sx=31, sy=31,

    change_state=function(this, to)
        this.state = to
    end,
    state = "icon",
    states = {
        icon=function (this)
            for i=1,grid.grid_size do
                for j=1,grid.grid_size do
                    left = (this.x + 1) + ((i-1) * 3)
                    top = (this.y + 1) + ((j-1) * 3)
                    right = (this.x + 1) + ((i) * 3) - 1
                    bottom = (this.y + 1) + ((j) * 3) - 1

                    rectfill(left, top, right, bottom, this.default[i][j])
                end
            end
        end,
        hint=function(this)
            for i=1,grid.grid_size do
                for j=1,grid.grid_size do
                    left = (this.x + 1) + ((i-1) * 3)
                    top = (this.y + 1) + ((j-1) * 3)
                    right = (this.x + 1) + ((i) * 3) - 1
                    bottom = (this.y + 1) + ((j) * 3) - 1

                    rectfill(left, top, right, bottom, grid.canvas[i + ((j - 1) * grid.grid_size)])
                end
            end
        end
    },

    default = {
        {13,13,13,13,13,13,13,13,13,13,},
        {13,1,1,1,13,1,1,13,13,13,},
        {13,1,1,13,13,1,1,1,13,13,},
        {13,13,13,13,13,1,1,1,14,13,},
        {13,9,12,14,13,1,1,14,14,13,},
        {13,8,11,10,13,7,1,14,14,13,},
        {13,13,13,13,13,1,1,1,14,13,},
        {13,1,1,1,13,1,1,1,13,13,},
        {13,1,1,13,13,1,1,13,13,13,},
        {13,13,13,13,13,13,13,13,13,13,},
    },

    

    _draw=function(this)
        rect(this.x, this.y, this.x + this.sx, this.y + this.sy, outline_color)

        this.states[this.state](this)

        if this.in_transition then
            rectfill(this.x + 1, this.y + 1, this.x + this.sx - 1, this.y + 1 + (this.sy - 2) * as_progress(state.transition_timer), transition_color)
        end
    end
}

// The space in which the player draws.
game_pane = {
    x=5, y=41, sx=81, sy=81,

    change_state=function(this, to)
        this.state = to
    end,
    state = "welcome",
    states = {
        welcome=function (this)
            print("pixel art panic", this.x + 5, this.y + 5, text_color)
            print("-", this.x + 5, this.y + 12, text_color)
            print("made for hackclub", this.x + 5, this.y + 19, text_color)
            print("siege week 6", this.x + 5, this.y + 28, text_color)
            print("by baton0", this.x + 5, this.y + 72, text_color)
        end,
        score=function(this)
            print("ran out of time!", this.x + 5, this.y + 5, text_color)
            print("-", this.x + 5, this.y + 12, text_color)
        
            print("reached level "..state.current_level, this.x + 5, this.y + 19, text_color)
            print("high: level "..state.highlevel, this.x + 5, this.y + 27, text_color)

            print("score: "..state.score, this.x + 5, this.y + 41, text_color)
            print("highscore: "..state.highscore, this.x + 5, this.y + 49, text_color)
        end,
        canvas=function(this)
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
    },

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
        rectline(this.x, this.y, this.sx, this.sy, pane_color, outline_color)

        this.states[this.state](this)

        cursor:_draw()

        if this.in_transition then
            rectfill(this.x + 1, this.y + 1, this.x + this.sx - 1, this.y + 1 + (this.sy - 2) * as_progress(state.transition_timer), transition_color)
        end
    end
}

// The space that tells the player more information about what is going on.
direct_pane = {
    x=41, y=5, sx=45, sy=31,


    change_state=function(this, to)
        this.state = to
    end,
    state = "instructions",
    states = {
        instructions=function(this)
            print("⬆️⬇️", this.x + 4, this.y + 5, 5)

            dy = 0 if btn(3) or btn(1) then dy = 1 end
            uy = 0 if btn(2) or btn(0) then uy = 1 end
            
            print("⬇️", this.x + 12,  this.y + 4 + dy, 6)
            print("⬆️", this.x + 4, this.y + 4 + uy, 6)

            print("NAVIGATE", this.x + 4, this.y + 10, text_color)

            xy = 0 if btn(5) then xy = 1 end

            print("❎", this.x + 4, this.y + 18, 5)
            print("❎", this.x + 4, this.y + 17 + xy, 6)

            print("SELECT", this.x + 4, this.y + 23, text_color)
        end,

        colors=function (this)
            offset = {x=this.x, y=this.y + 19}

            xy = 0 if btn(5) then xy = 1 end 
            oy = 0 if btn(4) then oy = 1 end

            print("<- DRAW!", this.x + 3, this.y + 4, text_color)

            print("🅾️", offset.x + 5,  offset.y - 4, 5)
            print("❎", offset.x + 35, offset.y - 4, 5)

            print("🅾️", offset.x + 5,  offset.y - 5 + oy, 6)
            print("❎", offset.x + 35, offset.y - 5 + xy, 6)

            // Display prev. cur. nex. colors.
            rectbord(offset.x,      offset.y + 2 + oy, offset.x + 15, offset.y + 12, this.colors.last,    0)
            rectline(offset.x + 15, offset.y,          15,            12,            this.colors.current, 0)
            rectbord(offset.x + 30, offset.y + 2 + xy, offset.x + 45, offset.y + 12, this.colors.next,    0)
        end
    },

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

    _draw=function(this)
        rectline(this.x, this.y, this.sx, this.sy, pane_color, outline_color)

        // Show the current pane.
        this.states[this.state](this)

        if this.in_transition then
            rectfill(this.x + 1, this.y + 1, this.x + this.sx - 1, this.y + 1 + (this.sy - 2) * as_progress(state.transition_timer), transition_color)
        end
    end
}

// The space that either gives more information or allows for customization.
menu_pane = {
    x=91, y=5, sx=32, sy=118,

    change_menu=function(this, to)
        this.index = 1
        this.current_menu = to
    end,
    menus = {
        main = 
        {
            options = {"start", "optns"},

            _update=function(this, menu)
                // Selecting a menu item
                if btnp(5) then
                    sfx(6)
                    if menu.options[this.index] == "start" then
                        state:transition({menu_pane, direct_pane, game_pane, hint_pane})
                        state.transition_calls["menu2start"]=function()
                            state:start_round()
                            this:change_menu("scoreboard")
                            direct_pane:change_state("colors")
                            game_pane:change_state("canvas")
                            hint_pane:change_state("hint")
                        end
                        
                elseif menu.options[this.index] == "optns" then
                        this:change_menu("optns")
                    end
                end
            end,

            _draw=function(this, menu)
                print("-menu-", this.x + 5, this.y + 5, text_color)
                for i=1,#menu.options do

                    message = menu.options[i] 
                    if i == this.index then message = ">"..tostr(menu.options[i]) end

                    print(message, this.x + 5, this.y + 7 +  (10 * i), text_color)
                end
            end
        },

        scoreboard = 
        {
            options = {},

            score = 0,

            _update=function(this, menu)
                menu.score = move_towards(menu.score, state.score, flr(abs(state.score - menu.score)/8))
            end,

            _draw=function (this, menu)
        
                print("time", this.x + 5, this.y + 6, text_color)
                print(ceil(state.draw_time), this.x + 5, this.y + 15)

                print("level", this.x + 5, this.y + 27)
                print(state.current_level, this.x + 5, this.y + 36)

                print("score", this.x + 5, this.y + 48)
                print(menu.score, this.x + 5, this.y + 57, text_color)

            end,
        },

        optns = 
        {
            options = {"screen", "outln", "pane", "text", "trnstn", "back"},

            _update=function (this, menu)
                // Selecting a menu item
                if btnp(5) then
                    sfx(6)
                    if menu.options[this.index] == "screen" then
                        background_color += 1 if background_color > 15 then background_color = 0 end
                    elseif menu.options[this.index] == "outln" then
                        outline_color += 1 if outline_color > 15 then outline_color = 0 end
                    elseif menu.options[this.index] == "pane" then
                        pane_color += 1 if pane_color > 15 then pane_color = 0 end
                    elseif menu.options[this.index] == "text" then
                        text_color += 1 if text_color > 15 then text_color = 0 end
                    elseif menu.options[this.index] == "trnstn" then
                        transition_color += 1 if transition_color > 15 then transition_color = 0 end
                    elseif menu.options[this.index] == "back" then
                        
                        this:change_menu("main")
                    end
                end
            end,

            _draw=function (this, menu)
                print("-optns-", this.x + 3, this.y + 5, text_color)
                for i=1,#menu.options do

                    message = menu.options[i] 
                    if i == this.index then message = ">"..tostr(menu.options[i]) end

                    print(message, this.x + 3, this.y + 7 +  (10 * i), text_color)
                end
            end
        },

        lose = 
        {
            options = {"again", "menu"},

            _update=function (this, menu)
                // Selecting a menu item
                if btnp(5) then
                    sfx(6)

                    state.current_level = 1
                    state.score = 0

                    if menu.options[this.index] == "again" then
                        state:transition({menu_pane, direct_pane, game_pane, hint_pane})
                        state.transition_calls["lose2game"]=function()
                            state:start_round()
                            this:change_menu("scoreboard")
                            direct_pane:change_state("colors")
                            game_pane:change_state("canvas")
                            hint_pane:change_state("hint")
                        end
                elseif menu.options[this.index] == "menu" then
                        this:change_menu("main")
                    end
                end
            end,

            _draw=function (this, menu)
                print("-lost-", this.x + 5, this.y + 5, text_color)
                for i=1,#menu.options do

                    message = menu.options[i] 
                    if i == this.index then message = ">"..tostr(menu.options[i]) end

                    print(message, this.x + 5, this.y + 7 +  (10 * i), text_color)
                end
            end
        },

    },

    _init=function (this)
        this.current_menu = "main"
    end,

    index = 1,
    control_index=function (this)
        // Controlling the menu index
        index = this.index
        options = this.menus[this.current_menu].options
        if btnp(2) or btnp(0) then index -= 1 sfx(0) end
        if btnp(3) or btnp(1) then index += 1 sfx(0) end

        // Clamp to the menu.
        if index > #options then index = 1
        elseif index < 1 then index = #options end

        this.index = index
    end,

    _update=function(this)
        if state.in_menu then this:control_index() end

        current_menu = this.menus[this.current_menu]

        current_menu._update(this, current_menu)
    end,

    _draw=function(this)
        rectline(this.x, this.y, this.sx, this.sy, pane_color, outline_color)

        current_menu = this.menus[this.current_menu]

        current_menu._draw(this, current_menu)

        if this.in_transition then
            rectfill(this.x + 1, this.y + 1, this.x + this.sx - 1, this.y + 1 + (this.sy - 2) * as_progress(state.transition_timer), transition_color)
        end
    end
}

cursor = {
    x=4, y=4,

    color = 1,
    
    move_delay = 3,
    move_timer = 0,
    control=function(this)
        nx = this.x ny = this.y

        // Control the next position
        this.move_timer = move_towards(this.move_timer, 0, 1)
        if     btn(0) and this.move_timer == 0 then nx -= 1 this.move_timer = this.move_delay
        elseif btn(1) and this.move_timer == 0 then nx += 1 this.move_timer = this.move_delay
        elseif btn(2) and this.move_timer == 0 then ny -= 1 this.move_timer = this.move_delay
        elseif btn(3) and this.move_timer == 0 then ny += 1 this.move_timer = this.move_delay 
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
        if btnp(5) then this.color += 1 sfx(4) end
        if btnp(4) then this.color -= 1 sfx(4) end

        if this.color > 15 then this.color = 0 end
        if this.color < 0 then this.color = 15 end

        direct_pane:update_colors()
    end,

    write=function(this)
        // Ignore if writing to a fufilled square / already that color
        if game_pane.canvas[this.x][this.y] == grid.canvas[this.x + ((this.y - 1) * grid.grid_size)] then return end
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
    menu_pane:_init()

    state:_init()

    direct_pane:update_colors()

    music(0)
end

function _update()
    cursor:_update()
    state:_update()
    menu_pane:_update()
end

function _draw()
    cls(background_color)

    // ⬇️⬆️⬅️➡️ fo. future reference

    hint_pane:_draw()
    game_pane:_draw()
    direct_pane:_draw()
    menu_pane:_draw()

    

    
end




__gfx__
11111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10200201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12222221000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10200201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10200201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12222221000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10200201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddd111111111111111111111111dddddddddddd999999999999888888888888dddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111dddddddddddd999999999999888888888888dddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111dddddddddddd999999999999888888888888dddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111dddddddddddd999999999999888888888888dddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111dddddddddddd999999999999888888888888dddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111dddddddddddd999999999999888888888888dddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111dddddddddddd999999999999888888888888dddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111dddddddddddd999999999999888888888888dddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111dddddddddddd999999999999888888888888dddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111dddddddddddd999999999999888888888888dddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111dddddddddddd999999999999888888888888dddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111dddddddddddd999999999999888888888888dddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111ddddddddddddccccccccccccbbbbbbbbbbbbdddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111ddddddddddddccccccccccccbbbbbbbbbbbbdddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111ddddddddddddccccccccccccbbbbbbbbbbbbdddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111ddddddddddddccccccccccccbbbbbbbbbbbbdddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111ddddddddddddccccccccccccbbbbbbbbbbbbdddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111ddddddddddddccccccccccccbbbbbbbbbbbbdddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111ddddddddddddccccccccccccbbbbbbbbbbbbdddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111ddddddddddddccccccccccccbbbbbbbbbbbbdddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111ddddddddddddccccccccccccbbbbbbbbbbbbdddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111ddddddddddddccccccccccccbbbbbbbbbbbbdddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111ddddddddddddccccccccccccbbbbbbbbbbbbdddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111ddddddddddddccccccccccccbbbbbbbbbbbbdddddddddddd111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111ddddddddddddddddddddddddeeeeeeeeeeeeaaaaaaaaaaaadddddddddddd111111111111dddddddddddddddddddddddd1111
1111dddddddddddd111111111111ddddddddddddddddddddddddeeeeeeeeeeeeaaaaaaaaaaaadddddddddddd111111111111dddddddddddddddddddddddd1111
1111dddddddddddd111111111111ddddddddddddddddddddddddeeeeeeeeeeeeaaaaaaaaaaaadddddddddddd111111111111dddddddddddddddddddddddd1111
1111dddddddddddd111111111111ddddddddddddddddddddddddeeeeeeeeeeeeaaaaaaaaaaaadddddddddddd111111111111dddddddddddddddddddddddd1111
1111dddddddddddd111111111111ddddddddddddddddddddddddeeeeeeeeeeeeaaaaaaaaaaaadddddddddddd111111111111dddddddddddddddddddddddd1111
1111dddddddddddd111111111111ddddddddddddddddddddddddeeeeeeeeeeeeaaaaaaaaaaaadddddddddddd111111111111dddddddddddddddddddddddd1111
1111dddddddddddd111111111111ddddddddddddddddddddddddeeeeeeeeeeeeaaaaaaaaaaaadddddddddddd111111111111dddddddddddddddddddddddd1111
1111dddddddddddd111111111111ddddddddddddddddddddddddeeeeeeeeeeeeaaaaaaaaaaaadddddddddddd111111111111dddddddddddddddddddddddd1111
1111dddddddddddd111111111111ddddddddddddddddddddddddeeeeeeeeeeeeaaaaaaaaaaaadddddddddddd111111111111dddddddddddddddddddddddd1111
1111dddddddddddd111111111111ddddddddddddddddddddddddeeeeeeeeeeeeaaaaaaaaaaaadddddddddddd111111111111dddddddddddddddddddddddd1111
1111dddddddddddd111111111111ddddddddddddddddddddddddeeeeeeeeeeeeaaaaaaaaaaaadddddddddddd111111111111dddddddddddddddddddddddd1111
1111dddddddddddd111111111111ddddddddddddddddddddddddeeeeeeeeeeeeaaaaaaaaaaaadddddddddddd111111111111dddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111777777777777111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111777777777777111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111777777777777111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111777777777777111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111777777777777111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111777777777777111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111777777777777111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111777777777777111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111777777777777111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111777777777777111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111777777777777111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111777777777777111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddddddd1111
1111dddddddddddddddddddddddd111111111111111111111111eeeeeeeeeeeeeeeeeeeeeeee111111111111111111111111dddddddddddddddddddddddd1111
1111dddddddddddddddddddddddd111111111111111111111111eeeeeeeeeeeeeeeeeeeeeeee111111111111111111111111dddddddddddddddddddddddd1111
1111dddddddddddddddddddddddd111111111111111111111111eeeeeeeeeeeeeeeeeeeeeeee111111111111111111111111dddddddddddddddddddddddd1111
1111dddddddddddddddddddddddd111111111111111111111111eeeeeeeeeeeeeeeeeeeeeeee111111111111111111111111dddddddddddddddddddddddd1111
1111dddddddddddddddddddddddd111111111111111111111111eeeeeeeeeeeeeeeeeeeeeeee111111111111111111111111dddddddddddddddddddddddd1111
1111dddddddddddddddddddddddd111111111111111111111111eeeeeeeeeeeeeeeeeeeeeeee111111111111111111111111dddddddddddddddddddddddd1111
1111dddddddddddddddddddddddd111111111111111111111111eeeeeeeeeeeeeeeeeeeeeeee111111111111111111111111dddddddddddddddddddddddd1111
1111dddddddddddddddddddddddd111111111111111111111111eeeeeeeeeeeeeeeeeeeeeeee111111111111111111111111dddddddddddddddddddddddd1111
1111dddddddddddddddddddddddd111111111111111111111111eeeeeeeeeeeeeeeeeeeeeeee111111111111111111111111dddddddddddddddddddddddd1111
1111dddddddddddddddddddddddd111111111111111111111111eeeeeeeeeeeeeeeeeeeeeeee111111111111111111111111dddddddddddddddddddddddd1111
1111dddddddddddddddddddddddd111111111111111111111111eeeeeeeeeeeeeeeeeeeeeeee111111111111111111111111dddddddddddddddddddddddd1111
1111dddddddddddddddddddddddd111111111111111111111111eeeeeeeeeeeeeeeeeeeeeeee111111111111111111111111dddddddddddddddddddddddd1111
1111ddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddd1111
1111ddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddd1111
1111ddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddd1111
1111ddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddd1111
1111ddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddd1111
1111ddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddd1111
1111ddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddd1111
1111ddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddd1111
1111ddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddd1111
1111ddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddd1111
1111ddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddd1111
1111ddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111

__sfx__
51030000284552d455004050040500405004050040500405004050040500405004050040500405004050040500400004000040000400004000040000000000000000000000000000000000000000000000000000
011000001a0501d05021050240501c0501f0501d050180501a0500000017050000000e05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
491000201105515055170550000513055000050e0550000500005000050e0550000510055000051105500005110551505517055000051305500005150550000500005000050c0550e05510055000051105500005
571000201954520505055451c5050b5451a5050654500505055450050523545005051a5450050505545175051954500505065450a5050b5450050504545005050554504545005050554500505075450950509505
910200000454313543185430060300603006030060300603006030060300603006030060300603006030060300603006030000300003000030000300003000030000300003000030000300003000030000300000
00020000116000b60002600076000c600136002460033600000000040003400094000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5103000024450304502b4502945029455000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
02 02420344

