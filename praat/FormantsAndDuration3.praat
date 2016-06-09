# Written by: Ed King
# Synopsis: 
# 1) Read in each .wav file in a directory, 
# 2) Save, as a tab-delimited CSV, the first two formants and the duration of each vowel.
# The script, by default, measures midpoint formants for monophthongs and midpoint, onset, and offset formants for diphthongs
# The default behavior can be changed to measure onset and offset formants for diphthongs

## Determine OS ##
osdet$ = environment$ ("OS")
## The environment variable %OS% (or $OS) only returns an answer in Windows; in Unix/OS X, it returns an empty string -- in those systems, the corresponding environment variable is $OSTYPE ##
if osdet$ <> ""
	os$ = "windows"
else
	os$ = "unix"
endif

## Set the directory separator, based on OS convention ##
if os$ = "unix"
	separator$ = "/"
elsif os$ = "windows"
	separator$ = "\"
endif

## Pop up the options form ##
form Options
	## Directory gets read from here, defaulting to current directory ##
	comment Choose directory (a single dot is the current directory)
	text directory .
	## Choose whether to measure formants at (1) midpoint (standard); (2) midpoint, onset, and offset; or (3) n equidistant points in each vowel ##
	comment At what points in the vowel should we measure formants?
	choice Measure: 1
		button Midpoint only
		button Midpoint, Onset, and Offset
		button Equidistant points
	comment If you chose equidistant points, how many points?
	comment (This field is required even if not measuring equidistant points)
		natural Points 3
	## Since Praat only allows one options form per script, you can only run this script on a set of files where all speakers are of one gender ##
	comment NOTE: All your recordings must be speakers of the same gender
	choice All_speakers_are: 1
		button Male
		button Female
endform
## End of options form ##

directory$ = directory$ + separator$

## Set up the log file ##
## Delete the old log file, if it exists ##
filedelete 'directory$'FormantsAndDuration-log.txt

## Setting the header for the logfile ##
header_row$ = "Filename" + tab$ + "Tier" + tab$ + "Label" + tab$ + "Duration" + tab$ + "Point" + tab$ + "F1" + tab$ + "F2" + newline$
## Then write the header to the logfile ##
header_row$ > 'directory$'FormantsAndDuration-log.txt
## Done writing header for logfile ##

## Set the appropriate max F3 value to use, depending on the given gender ##
if all_speakers_are$ = "Male"
	## 5000 Hz is the F3 max for males ##
	gen = 4500
else
	## 5500 Hz is the F3 max for females ##
	gen = 5000
endif
## Max F3 stored in variable gen ##

## Reading in a file list. Do some funky stuff to make sure extensions are case-insensitive (as long as case is consistent) ##
Create Strings as file list... part_wavfiles 'directory$'*.wav
if os$ = "unix"
	## Filenames are only case-sensitive on Unix systems. Doing this on a Windows system would read in all the files again ##
	Create Strings as file list... part_WAVfiles 'directory$'*.WAV
	plus Strings part_wavfiles
	Append
	Rename... WAVfiles
	select Strings part_wavfiles
	plus Strings part_WAVfiles
	Remove
else
	select Strings part_wavfiles
	Rename... WAVfiles
endif
## Done reading case-insensitive file list ##

## Run through control flow for each file in the file list ##
select Strings WAVfiles
numberOfFiles = Get number of strings
number = 1
for ifile from 1 to numberOfFiles
	select Strings WAVfiles
	fileName$ = Get string... ifile
	## Call procedure Windows for each file ##
	call Windows 'fileName$'
	## Call procedure DurationAndFormants for each file ##
	call DurationAndFormants 'name$'
	## Select the sound and its TextGrid, then remove them both ##
	select Sound 'name$'
	plus TextGrid 'name$'
	Remove
	## Increment the number and loop ##
	number = number + 1
endfor
## Now that everything's done, remove everything we've created ##
select Strings WAVfiles
Remove
## End of control flow ##

## procedure Windows: open the sound and its TextGrid ##
procedure Windows file_name$
Read from file... 'directory$''file_name$'
name$ = selected$ ("Sound")
labelfile$ = directory$+name$+".TextGrid"
	## Open the current sound's label file if it already exists ##
	if fileReadable (labelfile$)
		Read from file... 'directory$''name$'.TextGrid
	## If it doesn't already exist, create a TextGrid for it ##
	else
		To TextGrid... "vowels" ""
	endif
endproc
## End of procedure 'Windows' ##

## procedure DurationAndFormants: Determine the first, second, and third formants, and the duration, for each vowel ##
procedure DurationAndFormants name$
number_of_tiers = Get number of tiers
## Create a Formant with Praat's 'To Formant (burg)' function with the appropriate max F3 for this gender ##
select Sound 'name$'
To Formant (burg)... 0.0 5 gen 0.015 50
## For each tier... ##
for tnum from 1 to number_of_tiers
	select TextGrid 'name$'
	number_of_intervals = Get number of intervals... tnum
	## For each vowel... ##
	for vnum from 1 to number_of_intervals
		select TextGrid 'name$'
		interval_label$ = Get label of interval... tnum vnum
		## If the interval label is not blank, do some things... otherwise, ignore it ##
		if interval_label$ <> ""
			startV = Get starting point... tnum vnum
			endV = Get end point... tnum vnum
			## Calculate duration ##
			duration = (endV - startV) * 1000
			## Decide what times to measure at ##
				## For the midpoint, we'll just measure at 50% ##
				if measure = 1
					points = 1
					mid1 = (startV + endV) / 2
				## For the second measurement choice, we'll measure at 30%, 50%, and 70% ##
				elsif measure = 2
					points = 3
					mid1 = startV + (0.3 * (endV - startV))
					mid2 = (startV + endV) / 2
					mid3 = startV + (0.7 * (endV - startV))
				## For equidistant points, we have to calculate the times ##
				else
					for point from 1 to points
						mid'point' = (((point - 1)/(points - 1)) * (endV - startV)) + startV
					endfor
				endif
			## Times have been stored ##
			## For all of these times... ##
			for i from 1 to points
				## Determine point name ##
				## If we're just measuring the midpoint, then we'll call it 'midpoint' ##
				if measure = 1
					pt$ = "midpoint"
				## If we're measuring the standard three points, we'll call them 'onset', 'midpoint', and 'offset' ##
				elsif measure = 2
					if i = 1
						pt$ = "onset"
					elsif i = 2
						pt$ = "midpoint"
					elsif i = 3
						pt$ = "offset"
					else
						pt$ = "somewhere"
					endif
				## If we're measuring equidistant points, we'll call them by their number ##
				else
					pt$ = "'i'"
				endif
				select Formant 'name$'
				## Pull the first two formants at this time ##
				f1 = Get value at time... 1 mid'i' Hertz Linear
				f2 = Get value at time... 2 mid'i' Hertz Linear
				## Append our results to the current line ##
				curr_line$ = "'name$'" + tab$ + "'tnum'" + tab$ + "'interval_label$'" + tab$ + "'duration:2'" + tab$ + "'pt$'" + tab$ + "'f1:2'" + tab$ + "'f2:2'"
				## Write the current line to file ##
				fileappend "'directory$'FormantsAndDuration-log.txt" 'curr_line$' 'newline$'
			## End the 'for' loop over points ##
			endfor
		## End the 'if' statement corresponding to non-null labels ##	
		endif
	## End the 'for' loop over intervals ##
	endfor
## End the 'for' loop over tiers ##
endfor
select Formant 'name$'
Remove
endproc
## End the FormantsAndDuration procedure for the current file ##
