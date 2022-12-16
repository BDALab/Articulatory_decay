# This script extracts the fundamental frequency from the input *.wav file
# and saves to simple matrix file.

# Input parameters
# wav_pth - path to the *.wav file
# F0_pth - path to the output file
# real minimum_pitch - minimum pitch in Hz
# real maximum_pitch - maximum pitch in Hz

form Extract HNR
sentence wav_pth
sentence F0_pth
real minimum_pitch
real maximum_pitch
endform

soundID = Read from file... 'wav_pth$'

select soundID
pitchID = To Pitch... 0.0 minimum_pitch maximum_pitch

select pitchID
mtxID = To Matrix

select mtxID
Save as matrix text file... 'F0_pth$'