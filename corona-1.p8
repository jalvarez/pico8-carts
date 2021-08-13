pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function _init()
 t = 0
	nave = { s = 1,
										x = 60, 
										y = 60,
										h = 4,
										p = 0,
										imm = false,
										imm_t = 0,
										box = {
											x1 = 3,
											y1 = 0,
											x2 = 5,
											y2 = 7 }
								}
	balas = {}
	virus = {}
 explosiones = {}
 globulos = {}
 
 for i=1,128 do
 	add(globulos,
 	    { x = rnd(128),
 	      y = rnd(128),
 	      s = rnd(2) + 1
 	    })
 end 
 
	
	empezar()
end

function respaunear()
 local n = flr(rnd(6)) + 2
	for i = 1,n do
	 local d = -1
	 if rnd(1) < 0.5 then d = 1 end
	 
	 local v = { s = 17,
													 mx = 10 + 20 * i,
														my = -20 - 5 * i,
														x = -32,
														y = -32,
														d = d,
														r = 30,
														box = {
															x1 = 0,
															y1 = 0,
															x2 = 7,
															y2 = 7 }
												}
		add(virus, v)
	end
end

function empezar()
	_update = update_juego
	_draw = draw_juego
end


function game_over()
	_update = update_game_over
	_draw = draw_game_over
end


function disparar()
	local b = { s = 3,
												 x = nave.x,
												 y = nave.y,
												 dx = 0,
												 dy = -5,
												 box = {
														x1 = 3,
														y1 = 0,
														x2 = 5,
														y2 = 2 } 
													}
	add(balas, b)
end

function explosion(x,y)
	add(explosiones, {	x = x, 
																				y = y,
																				t = 0 })
end

function abs_box(s)
	local box = {}
	box.x1 = s.x + s.box.x1
	box.y1 = s.y + s.box.y1
	box.x2 = s.x + s.box.x2
	box.y2 = s.y + s.box.y2
	return box
end

function ha_chocado(a, b)
 local box_a = abs_box(a)
 local box_b = abs_box(b)
 
 if box_a.x1 > box_b.x2 or
 			box_a.y1 > box_b.y2 or
 			box_b.x1 > box_a.x2 or
 			box_b.y1 > box_a.y2 then
 				return false
 end
 return true
end

function update_juego()
 t = t + 1
 
 if nave.imm then
 	nave.imm_t += 1
 	if nave.imm_t > 30 then
 		nave.imm = false
 		nave.imm_t = 0
 	end
 end
 
 if (t%8 < 6) then
 	nave.s = 1
 else
 	nave.s = 2
 end
 
 if #virus <= 0 then
 	respaunear()
 end
 
 for b in all(balas) do
 	b.x += b.dx
 	b.y += b.dy
 	if b.y < 0 or b.y > 128 
 		or b.x < 0 or b.x > 128 then
 			del(balas, b)
 	end
 	
 	for v in all(virus) do
 		if ha_chocado(v, b) then
 			del(virus, v)
 			nave.p += 1
 			explosion(v.x, v.y)
 		end
 	end
 end
 
 for v in all(virus) do
  v.my += 1.3
 	v.x = v.r * sin(v.d * t/50) + v.mx
 	v.y = v.r * cos(t/50) + v.my
 	
 	if ha_chocado(v,nave) and 
 				not nave.imm then
 	 			nave.imm = true
 					nave.h -= 1
 					if (nave.h < 1) then
 						game_over()
 					end
 	end
 	
 	if v.y > 150 then
 		del(virus, v)
 	end
 end
 
 for gb in all(globulos) do
 	gb.y += gb.s
 	if gb.y >= 128 then
 		gb.y = 0
 		gb.x = rnd(128)
 	end
 end
 
 for ex in all(explosiones) do
 	ex.t += 1
 	if (ex.t == 13) then
 		del(explosiones, ex)
 	end
 end
 
 if (btn(0)) then nave.x -= 1 end
 if (btn(1)) then nave.x += 1 end
 if (btn(2)) then nave.y -= 1 end
 if (btn(3)) then nave.y += 1 end
 if (btnp(4)) then disparar() end
end

function draw_juego()
 cls()
 
 for gb in all(globulos) do
 	pset(gb.x, gb.y, 15)
 end
 
 print(nave.p)
 
 if not nave.imm or t%8 > 4 then
		spr(nave.s, nave.x, nave.y)
	end
	
	for b in all(balas) do
		spr(b.s, b.x, b.y)
	end
	
	for v in all(virus) do
		spr(v.s, v.x, v.y)
	end
	
	for ex in all(explosiones) do
		circ(ex.x, ex.y, ex.t/3, 8 + ex.t%3)
	end
	
	for i = 1,4 do
		if i <= nave.h then
			spr(33, 90 + i * 6, 3)
		else
		 spr(34, 90 + i * 6, 3)
		end
	end
end

function draw_game_over()
	cls()
	print("game over", 50, 50, 4)
	print("score = " .. nave.p,
					  50, 70, 12) 
end

function update_game_over()
	if (btnp(5)) then 
		_init()
	end	
end
__gfx__
00000000000060000000600000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000060000000600000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000060000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000606000006060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000686000006860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000686000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000060000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000b0bbb0b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000bbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbb8bb8b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000bbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbb7bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000b7b7b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000b0bbb0b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008080000060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088888000666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008880000066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000800000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
