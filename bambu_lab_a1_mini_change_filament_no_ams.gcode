;===== Latest change filament code (no AMS for A1 Mini) can be found at:
;===== https://github.com/Dennis-Q/bambu
;=====
;===== Based on work of eukatree and some contributors (Hillbilly-Phil and pakonambawan)
;===== https://github.com/eukatree/Bambu_CustomGCode/
;=====
;===== Updated: 20250127
;================================================
;
;===== Install instructions (Bambu Studio / Orca Slicer):
;===== Copy this complete file (including all comments)
;===== to the 'Change filament G-code'-section which can be 
;===== found in 'Printer settings' - 'Machine code' menu.
;===== Then, save the printer and use it with multi-color prints.
;
;===== Instructions (by Hillbilly-Phil): =====
; when print has paused, go into control
; set the nozzle temp to the temp you were printing with
; unload the filament by pushing on the upper extruder-button 
; load the new filament by pushing on the lower extruder-button 
; resume the print (flushing will happen next,
; flushing volumes can be set in Bambu Studio as if using an AMS)
;
;===== machine: A1 mini =========================
;===== date: 20240830  =======================
G392 S0
M1007 S0
;M620 S[next_extruder]A ; REMOVED: skips all next code if no AMS is available
M204 S9000
{if toolchange_count >= 1}
G17
G2 Z{max_layer_z + 0.4} I0.86 J0.86 P1 F10000 ; spiral lift a little from second lift
;=endif= ; MOVED DOWN: To ensure all needed code is executed. Changed curly braces signs to equal signs to solve parse error.
G1 Z{max_layer_z + 3.0} F1200

M400
M106 P1 S0
M106 P2 S0
{if old_filament_temp > 142 && next_extruder < 255}
M104 S[old_filament_temp]
{endif}

G1 X185 F18000 ; moves next to cutting position
M17 S ; saves the default stepper current values
M400 ; waits for commands to complete
M17 X1 ; sets x stepper current higher
G1 X197 F400 ; cuts filament a little slower, ADDED: finetuning by pakonambawan
G1 X185 F500 ; returns back to position before cutting, ADDED: finetuning by pakonambawan
M400 ; waits for commands to complete
M17 R ; restores saved stepper current values

M620.1 E F[old_filament_e_feedrate] T{nozzle_temperature_range_high[previous_extruder]}
M620.10 A0 F[old_filament_e_feedrate]
T[next_extruder]
M620.1 E F[new_filament_e_feedrate] T{nozzle_temperature_range_high[next_extruder]}
M620.10 A1 F[new_filament_e_feedrate] L[flush_length] H[nozzle_diameter] T[nozzle_temperature_range_high]

;G1 Y90 F9000 ; REMOVED from original GCODE
; -- BEGIN ADDED LINES --
G1 X0 Y90 F18000
G1 X-13.5 F9000
G1 E-13.5 F900

M109 S[old_filament_temp]

;START PLAY SOUND
M17
M400 S1
M1006 S1
M1006 A0 B20 L100 C37 D20 M40 E42 F20 N60
M1006 A0 B20 L100 C37 D20 M40 E42 F20 N60
M1006 A0 B20 L100 C37 D20 M100 E37 F20 N100
;END PLAY SOUND

; pause for user to load and press resume
M400 U1
; -- END ADDED LINES --

{if next_extruder < 255}
M400

G92 E0
;M628 S0 ; REMOVED: causes printer to crash without AMS

{if flush_length_1 > 1}
; FLUSH_START
; always use highest temperature to flush
M400
M1002 set_filament_type:UNKNOWN
M109 S[nozzle_temperature_range_high]
M106 P1 S60
{if flush_length_1 > 23.7}
G1 E23.7 F{old_filament_e_feedrate} ; do not need pulsatile flushing for start part
G1 E{(flush_length_1 - 23.7) * 0.02} F50
G1 E{(flush_length_1 - 23.7) * 0.23} F{old_filament_e_feedrate}
G1 E{(flush_length_1 - 23.7) * 0.02} F50
G1 E{(flush_length_1 - 23.7) * 0.23} F{new_filament_e_feedrate}
G1 E{(flush_length_1 - 23.7) * 0.02} F50
G1 E{(flush_length_1 - 23.7) * 0.23} F{new_filament_e_feedrate}
G1 E{(flush_length_1 - 23.7) * 0.02} F50
G1 E{(flush_length_1 - 23.7) * 0.23} F{new_filament_e_feedrate}
{else}
G1 E{flush_length_1} F{old_filament_e_feedrate}
{endif}
; FLUSH_END
G1 E-[old_retract_length_toolchange] F1800
G1 E[old_retract_length_toolchange] F300
M400
M1002 set_filament_type:{filament_type[next_extruder]}
{endif}


M629

M400
M106 P1 S60
M109 S[new_filament_temp]
G1 E5 F{new_filament_e_feedrate} ;Compensate for filament spillage during waiting temperature
M400
G92 E0
G1 E-[new_retract_length_toolchange] F1800
M400
M106 P1 S178
M400 S3
G1 X-3.5 F18000
G1 X-13.5 F3000
G1 X-3.5 F18000
G1 X-13.5 F3000
G1 X-3.5 F18000
G1 X-13.5 F3000
G1 X-3.5 F18000
G1 X-13.5 F3000
M400
G1 Z{max_layer_z + 3.0} F3000
M106 P1 S0
{if layer_z <= (initial_layer_print_height + 0.001)}
M204 S[initial_layer_acceleration]
{else}
M204 S[default_acceleration]
{endif}
{else}
G1 X[x_after_toolchange] Y[y_after_toolchange] Z[z_after_toolchange] F12000
{endif}

; -- BEGIN ADDED LINES --
{endif}
M620 S[next_extruder]A
T[next_extruder]
; -- END ADDED LINES --
M621 S[next_extruder]A


M622.1 S0

M9833 F{outer_wall_volumetric_speed/2.4} A0.3 ; cali dynamic extrusion compensation
M1002 judge_flag filament_need_cali_flag
M622 J1
  G92 E0
  G1 E-[new_retract_length_toolchange] F1800
  M400
  
  M106 P1 S178
  M400 S7
  G1 X0 F18000
  G1 X-13.5 F3000
  G1 X0 F18000 ;wipe and shake
  G1 X-13.5 F3000
  G1 X0 F12000 ;wipe and shake
  G1 X-13.5 F3000
  G1 X0 F12000 ;wipe and shake
  M400
  M106 P1 S0 
M623

G392 S0
M1007 S1
