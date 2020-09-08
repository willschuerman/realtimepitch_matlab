form Test command line calls
    real pitch_time_step 0.0
	real minimum_pitch 70
	integer no_candidates 10
	integer very_accurate 1
	real silence_threshold 0.03
    real voicing_threshold 0.005
	real octave_cost 0.0001	
	real octave_jump_cost 3
	real voiced_unvoiced_cost 2
	real maximum_pitch 300
endform

wavfilename$ = "s4p.wav"
pitchfilename$ = "s4p.praat_pitch"
Read from file... 'wavfilename$'
sound = selected ("Sound", -1)
selectObject: sound
To Pitch (ac): pitch_time_step, minimum_pitch, no_candidates, very_accurate, silence_threshold, voicing_threshold, octave_cost, octave_jump_cost, voiced_unvoiced_cost, maximum_pitch
pitch = selected ("Pitch", -1)
selectObject: pitch
Save as text file: pitchfilename$
selectObject ( ) ; deselect all objects
#removeObject: sound, pitch

