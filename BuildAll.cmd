setlocal
if exist *.rom del *.rom
call Build 20MX2 && ren S2I.rom s2i_20MX2.rom
call Build 1GX2 && ren S2I.rom s2i_1GX2.rom
call Clean
