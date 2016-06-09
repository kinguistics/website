clearinfo
Erase all
form Enter variables
optionmenu Adjust_token 1
option a
option b
real Steps 11
real Prediction_order 10
real Analysis_window 0.075
real Time_step 0.005
real Initial_frame_offset 1
real Final_frame_offset 1
real Minimum_intensity 0
real Max_f5 5000
optionmenu Method 1
option Dynamic
option Static
word Start_vowel
word Word_a
word Word_b
word Environment
real Offset 0
boolean Write_file 0
boolean Write_HTML 0
sentence Directory C:\
endform

#DURATION ADJUSTMENT
master_sound_a=selected("Sound")
master_sound_a$=selected$("Sound")
master_textgrid_a=selected("TextGrid")

select master_sound_a
Resample... 2*'max_f5' 50
Rename... 'master_sound_a$'_resamp
new_master_a = selected("Sound")
#select master_sound_a
#Remove
master_sound_a = new_master_a

select master_textgrid_a
nintervals = Get number of intervals... 1

for current_interval from 1 to nintervals
	label$ = Get label of interval... 1 current_interval
	if label$="a"
		start_a = Get starting point... 1 current_interval
		end_a = Get end point... 1 current_interval
	endif
endfor


pause Select the other pair
master_sound_b=selected("Sound")
master_sound_b$=selected$("Sound")
master_textgrid_b=selected("TextGrid")

select master_sound_b
Resample... 2*'max_f5' 50
Rename... 'master_sound_b$'_resamp
new_master_b = selected("Sound")
#select master_sound_b
#Remove
master_sound_b = new_master_b

select master_textgrid_b

nintervals = Get number of intervals... 1

for current_interval from 1 to nintervals
	label$ = Get label of interval... 1 current_interval
	if label$="b"
		start_b = Get starting point... 1 current_interval
		end_b = Get end point... 1 current_interval
	endif
endfor

		

duration_a = end_a-start_a
duration_b = end_b-start_b

diff_ab = (duration_a-duration_b)/2
diff_factor = abs(diff_ab)

if duration_a > duration_b
	target_duration_a=duration_a - diff_factor	
	target_duration_b=duration_b + diff_factor
else
	target_duration_a=duration_a + diff_factor	
	target_duration_b=duration_b - diff_factor
	
endif

if target_duration_a=target_duration_b
	target_duration=target_duration_a
	
else
	print 'duration_a''newline$''duration_b''newline$''diff_factor''newline$'
	print 'target_duration_a''newline$''target_duration_b'
	stop ERROR
endif
scale_factor_a = target_duration/duration_a
scale_factor_b = target_duration/duration_b


call duration_a
call duration_b

#LPC
select sound_duration_adjusted_a
Extract part... start_a start_a+target_duration "rectangular" 1 no
Rename... 'master_sound_a$'_LPC_master
lpc_master_sound_a = selected("Sound")
To LPC (burg)... prediction_order analysis_window time_step 50
lpc_master_a = selected("LPC")
To Formant
formant_master_a = selected("Formant")
one_third_a=target_duration/3
f1_static_a=Get value at time... 1 one_third_a Hertz Linear
f2_static_a=Get value at time... 2 one_third_a Hertz Linear
f3_static_a=Get value at time... 3 one_third_a Hertz Linear

Speckle... 0 0 3000 30 yes
#Track... 3 500 1500 2500 3850 4950 1 1 1
Down to FormantTier
Down to TableOfReal... yes no
nrow=Get number of rows

table_master_a = selected("TableOfReal")

select lpc_master_sound_a
To Intensity... 100 time_step
intensity_master_a = selected("Intensity")

select lpc_master_sound_a
plus lpc_master_a
Filter (inverse)
Rename... Source 'master_sound_a$'_LPC_master
source_a = selected("Sound")

select sound_duration_adjusted_b
Extract part... start_b start_b+target_duration "rectangular" 1 no
Rename... 'master_sound_b$'_LPC_master
lpc_master_sound_b = selected("Sound")
To LPC (burg)... prediction_order analysis_window time_step 50
lpc_master_b = selected("LPC")
To Formant
formant_master_b = selected("Formant")
one_third_b=target_duration/3
f1_static_b=Get value at time... 1 one_third_b Hertz Linear
f2_static_b=Get value at time... 2 one_third_b Hertz Linear
f3_static_b=Get value at time... 3 one_third_b Hertz Linear

#Track... 3 500 1500 2500 3850 4950 1 1 1
Down to FormantTier
Down to TableOfReal... yes no
nrow=Get number of rows
table_master_b = selected("TableOfReal")
Create TableOfReal... increments nrow 3
table_increments = selected("TableOfReal")


#print Frame'tab$'F1 incr'tab$'F2 incr'newline$'

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

#Get static increments
	f1_static_diff = abs(f1_static_a-f1_static_b)
	f2_static_diff = abs(f2_static_a-f2_static_b)
	f3_static_diff = abs(f3_static_a-f3_static_b)
endif
f1_static_incr = f1_static_diff/steps
f2_static_incr = f2_static_diff/steps
f3_static_incr = f3_static_diff/steps

f3_static_fixed = f3_static_a + ((f3_static_a-f3_static_b)/2)
for current_step from 1 to steps

	select formant_master_a
	nframes = Get number of frames
		for current_frame from initial_frame_offset to nframes-final_frame_offset
		select table_increments
		f1_incr = Get value... current_frame 1
		f2_incr = Get value... current_frame 2
		f3_incr = Get value... current_frame 3
		select intensity_master_a
		inten = Get value in frame... current_frame
		select formant_master_a
		
		if method$ = "Dynamic"
			method_abbr$ = "d"
			
			if current_step = 1
				f1_incr = 0
				f2_incr = 0
				f3_incr = 0
			endif
			
			#if inten>=minimum_intensity
			Formula (frequencies)... if row = 1 and col = current_frame then self - f1_incr else self fi
			Formula (frequencies)... if row = 2 and col = current_frame then self - f2_incr else self fi
			Formula (frequencies)... if row = 3 and col = current_frame then self - f3_incr else self fi
			#endif
			
		endif
		
		if method$ = "Static"
			method_abbr$ = "s"
		

			select formant_master_a
			if f1_static_a > f1_static_b
				Formula (frequencies)... if row = 1 and col = current_frame then (self-self) +  (f1_static_a - (f1_static_incr*(current_step-1))) else self fi
			else
				Formula (frequencies)... if row = 1 and col = current_frame then (self-self) +  (f1_static_a + (f1_static_incr*(current_step-1))) else self fi
				
			endif
			
			if f2_static_a > f2_static_b
				Formula (frequencies)... if row = 2 and col = current_frame then (self-self) +  (f2_static_a - (f2_static_incr*(current_step-1))) else self fi
			else
				Formula (frequencies)... if row = 2 and col = current_frame then (self-self) +  (f2_static_a + (f2_static_incr*(current_step-1))) else self fi
				
			endif

			#if f3_static_a > f3_static_b
			#	Formula (frequencies)... if row = 3 and col = current_frame then (self-self) +  (f3_static_a - (f3_static_incr*(current_step-1))) else self fi
			#else
			#	Formula (frequencies)... if row = 3 and col = current_frame then (self-self) +  (f3_static_a + (f3_static_incr*(current_step-1))) else self fi
			#endif

			Formula (frequencies)... if row = 3 and col = current_frame then (self-self) + f3_static_fixed else self fi
		endif

	endfor
	

	#if current_step=steps
		Red
		Speckle... 0 0 3000 30 no
		Black
	#endif
	
	Copy... step_'current_step'	

	plus source_a
	Filter
	Rename... step_'current_step'
	Scale peak... 0.99
	
	if current_step < 10
		zero$="0"
	else
		zero$=""
	endif
	if write_file = 1
		step_adj= current_step-offset
		Write to WAV file... 'directory$''zero$''step_adj'_'start_vowel$'_'environment$'_'method_abbr$'.wav
	endif
	#select Formant step_'current_step'
	#Remove
	
	
	
	if write_HTML = 1
		#dir$ = "C:\10000\"
		step_adj= current_step-offset
		filename$ = "'zero$''step_adj'_'start_vowel$'_'environment$'_'method_abbr$'"
		#html_file$ = "'directory$''zero$''current_step'_'start_vowel$'_'environment$'_'method_abbr$'.html"
		html_file$ ="'directory$''filename$'.html"

		filedelete 'html_file$'
		
	
		fileappend "'html_file$'" 'newline$'<table width="200" height="150" border="0" align="center" cellpadding="5" cellspacing="0" bgcolor="#CCCCCC">
		fileappend "'html_file$'" 'newline$'    <tr>
		fileappend "'html_file$'" 'newline$'      <td><p align="center"><strong>'master_sound_a$' or 'master_sound_b$'? </strong></p>        <table border="1" align="center" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC" bgcolor="#FFFFFF">
		fileappend "'html_file$'" 'newline$'	<tr>
		fileappend "'html_file$'" 'newline$'	  <td width="130"><table width="100" border="0" align="center" cellpadding="5" cellspacing="5">
		fileappend "'html_file$'" 'newline$'	      <tr>
		fileappend "'html_file$'" 'newline$'		<td><strong>PLAY:</strong></td>
		fileappend "'html_file$'" 'newline$'		<td><object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0" width="50" height="35" align="middle">
		fileappend "'html_file$'" 'newline$'		    <param name="movie" value="http://bartus.org/media/'filename$'.swf">
		fileappend "'html_file$'" 'newline$'		    <param name="quality" value="high">
		fileappend "'html_file$'" 'newline$'		    <embed src="http://bartus.org/media/'filename$'.swf" width="50" height="35" align="middle" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash"></embed>
		fileappend "'html_file$'" 'newline$'		</object></td>
		fileappend "'html_file$'" 'newline$'	      </tr>
		fileappend "'html_file$'" 'newline$'	  </table></td>
		fileappend "'html_file$'" 'newline$'	</tr>
		fileappend "'html_file$'" 'newline$'      </table></td>
		fileappend "'html_file$'" 'newline$'    </tr>
	 	fileappend "'html_file$'" 'newline$'</table>
	 endif
endfor
		select all
		Write to binary file... 'directory$''start_vowel$'_'environment$'_'method_abbr$'.Collection
		call log_settings


procedure duration_a
select master_sound_a
master_duration_a=Get total duration
To Manipulation... 0.01 75 600
master_manipulation_a = selected("Manipulation")
Extract duration tier
Rename... dur_adjusted
master_duration_tier_a = selected("DurationTier")
start_notch_a = start_a + 0.0005
end_notch_a = end_a - 0.0005
start_notch_b = start_b + 0.0005
end_notch_b = end_b - 0.0005
Add point... start_a 1
Add point... start_notch_a scale_factor_a
Add point... end_a 1
Add point... end_notch_a scale_factor_a
	
select master_manipulation_a
plus master_duration_tier_a
Replace duration tier
select master_manipulation_a
Get resynthesis (PSOLA)
Rename... 'master_sound_a$'_adjusted
sound_duration_adjusted_a=selected("Sound")
endproc

procedure duration_b
select master_sound_b
master_duration_b=Get total duration
To Manipulation... 0.01 75 600
master_manipulation_b = selected("Manipulation")
Extract duration tier
Rename... dur_adjusted
master_duration_tier_b = selected("DurationTier")
start_notch_a = start_a + 0.0005
end_notch_a = end_a - 0.0005
start_notch_b = start_b + 0.0005
end_notch_b = end_b - 0.0005
Add point... start_b 1
Add point... start_notch_b scale_factor_b
Add point... end_a 1
Add point... end_notch_b scale_factor_b
	
select master_manipulation_b
plus master_duration_tier_b
Replace duration tier
select master_manipulation_b
Get resynthesis (PSOLA)
Rename... 'master_sound_b$'_adjusted
sound_duration_adjusted_b=selected("Sound")
endproc

procedure log_settings
clearinfo
print 'newline$' Steps: 'steps'
print 'newline$' Prediction_order: 'prediction_order'
print 'newline$' Analysis_window: 'analysis_window'
print 'newline$' Time_step: 'time_step'
print 'newline$' Initial_frame_offset: 'initial_frame_offset'
print 'newline$' Final_frame_offset 'final_frame_offset'
print 'newline$' Method: 'method$'
print 'newline$' Start_vowel: 'start_vowel$'
print 'newline$' Word_a: 'word_a$'
print 'newline$' Word_b: 'word_b$'
print 'newline$' Environment: 'environment$'
print 'newline$' Offset: 'offset'
print 'newline$' Directory 'directory$'

#Write to log file

filedelete 'directory$''start_vowel$'_'environment$'_'method_abbr$'.txt
fileappend 'directory$''start_vowel$'_'environment$'_'method_abbr$'.txt SYNTHESIS SETTINGS 'newline$'
fileappend 'directory$''start_vowel$'_'environment$'_'method_abbr$'.txt 'newline$' Steps: 'steps'
fileappend 'directory$''start_vowel$'_'environment$'_'method_abbr$'.txt  'newline$' Prediction_order: 'prediction_order'
fileappend 'directory$''start_vowel$'_'environment$'_'method_abbr$'.txt  'newline$' Analysis_window: 'analysis_window'
fileappend 'directory$''start_vowel$'_'environment$'_'method_abbr$'.txt  'newline$' Time_step: 'time_step'
fileappend 'directory$''start_vowel$'_'environment$'_'method_abbr$'.txt  'newline$' Initial_frame_offset: 'initial_frame_offset'
fileappend 'directory$''start_vowel$'_'environment$'_'method_abbr$'.txt  'newline$' Final_frame_offset 'final_frame_offset'
fileappend 'directory$''start_vowel$'_'environment$'_'method_abbr$'.txt  'newline$' Method: 'method$'
fileappend 'directory$''start_vowel$'_'environment$'_'method_abbr$'.txt  'newline$' Start_vowel: 'start_vowel$'
fileappend 'directory$''start_vowel$'_'environment$'_'method_abbr$'.txt  'newline$' Word_a: 'word_a$'
fileappend 'directory$''start_vowel$'_'environment$'_'method_abbr$'.txt  'newline$' Word_b: 'word_b$'
fileappend 'directory$''start_vowel$'_'environment$'_'method_abbr$'.txt  'newline$' Environment: 'environment$'
fileappend 'directory$''start_vowel$'_'environment$'_'method_abbr$'.txt  'newline$' Offset: 'offset'
fileappend 'directory$''start_vowel$'_'environment$'_'method_abbr$'.txt  'newline$' Directory 'directory$'

endproc

procedure quit
select all
minus master_sound_a
minus master_textgrid_a
minus master_sound_b
minus master_textgrid_b
Remove
select master_sound_a
plus master_textgrid_a
endproc