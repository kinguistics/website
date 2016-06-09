clearinfo
Erase all
form Enter variables
real Steps 11
real Initial_frame_offset 1
real Final_frame_offset 1
endform

select Formant a
formant_master_a = selected("Formant")
select Sound source
source_a = selected("Sound")
select Formant b
formant_master_b = selected("Formant")

select formant_master_a
Copy... a_mod
formant_mod_a = selected("Formant")

select formant_master_a
Speckle... 0 0 5000 30 yes
#Track... 3 500 1500 2500 3850 4950 1 1 1
Down to FormantTier
Down to TableOfReal... yes no
nrow=Get number of rows

table_master_a = selected("TableOfReal")

select formant_master_b
Down to FormantTier
Down to TableOfReal... yes no
nrow=Get number of rows
table_master_b = selected("TableOfReal")
Create TableOfReal... increments nrow 3
table_increments = selected("TableOfReal")


for current_row from 1 to nrow
	select table_master_a
	f1_a = Get value... current_row 2
	f2_a = Get value... current_row 3
	f3_a = Get value... current_row 4
	select table_master_b
	f1_b = Get value... current_row 2
	f2_b = Get value... current_row 3
	f3_b = Get value... current_row 4
	f1_incr = (f1_a-f1_b)/steps
	f2_incr = (f2_a-f2_b)/steps
	f3_incr = (f3_a-f3_b)/steps
		
	#print 'newline$''current_row''tab$''f1_incr:0''tab$''f2_incr:0'
	select table_increments
	Set value... current_row 1 'f1_incr:0'
	Set value... current_row 2 'f2_incr:0'
	Set value... current_row 3 'f3_incr:0'
	
endfor

for current_step from 1 to steps
	select formant_mod_a
	nframes = Get number of frames
		for current_frame from initial_frame_offset to nframes-final_frame_offset
			select table_increments
			f1_incr = Get value... current_frame 1
			f2_incr = Get value... current_frame 2
			f3_incr = Get value... current_frame 3
			select formant_mod_a
		
				method_abbr$ = "d"
			
				if current_step = 1
					f1_incr = 0
					f2_incr = 0
					f3_incr = 0
				endif
			
				Formula (frequencies)... if row = 1 and col = current_frame then self - f1_incr else self fi
				Formula (frequencies)... if row = 2 and col = current_frame then self - f2_incr else self fi
				Formula (frequencies)... if row = 3 and col = current_frame then self - f3_incr else self fi
					
		endfor
	

	#if current_step=steps
		Red
		Speckle... 0 0 5000 30 no
		Black
	#endif
	
	Copy... step_'current_step'	

	plus source_a
	Filter
	Rename... step_'current_step'
	Scale peak... 0.99	
endfor
		
select all
Write to binary file... 'directory$''start_vowel$'_'environment$'_'method_abbr$'.Collection