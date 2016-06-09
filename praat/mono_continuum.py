import wave,struct,sys,numpy

fname_a = sys.argv[1]
fname_b = sys.argv[2]
steps = int(sys.argv[3])

awavf = wave.open(fname_a)
bwavf = wave.open(fname_b)

allframes_a = awavf.readframes(-1)
allframes_b = bwavf.readframes(-1)

awavf.close()
bwavf.close()

aframes = numpy.array(struct.unpack('%sh' % (len(allframes_a)/struct.calcsize('h')),allframes_a))
bframes = numpy.array(struct.unpack('%sh' % (len(allframes_b)/struct.calcsize('h')),allframes_b))

minframes = min(len(aframes),len(bframes))
aframes = aframes[:minframes]
bframes = bframes[:minframes]

diffarray = (bframes-aframes)/float(steps-1)
currarray = aframes

sampwidth = awavf.getsampwidth()
framerate = awavf.getframerate()

fname_base = fname_a.replace('.wav','')+'_'+fname_b.replace('.wav','')

for stepnum in range(steps):
	# back to byte string
	frames_to_write = ''
	for val in currarray:
		frames_to_write += struct.pack('h',val)
	fname_out = fname_base+str(stepnum+1)+'.wav'

	fout = wave.open(fname_out,'w')
	fout.setnchannels(1)
	fout.setsampwidth(sampwidth)
	fout.setframerate(framerate)
	fout.writeframes(frames_to_write)

	fout.close()
	
	currarray = currarray+diffarray
