function vo = praat_voicing(y, fs, minimum_pitch, maximum_pitch, n_seg)

% based on the fundamental frequency:
% The Praat console application praatcon.exe and script praat_F0.praat
% is required.
% 
% y                 - input column signal
% fs                - sampling frequency
% minimum_pitch     - minimum frequency (default: 75Hz)
% maximum_pitch     - minimum frequency (default: 400Hz)
% n_seg             - length of output vector; if set to -1 the length will
%                     be determined by Praat (default: -1)
% vo                - output vector indicating the voicing segments

%% Paths and variables
if((nargin < 3) || isempty(minimum_pitch))
    minimum_pitch = 75;
end
if((nargin < 4) || isempty(maximum_pitch))
    maximum_pitch = 400;
end
if((nargin < 5) || isempty(n_seg))
    n_seg = -1;
end

dir_pth = [fileparts(mfilename('fullpath')) filesep];

%% Store signal to the temporary *.wav file
wav_pth = [pwd filesep num2str(round(rand(1,1)*1e5)) '.wav'];
while(exist(wav_pth, 'file'))
    wav_pth = [pwd filesep num2str(round(rand(1,1)*1e5)) '.wav'];
end

audiowrite(wav_pth, y, fs);

%% Prepare and run Praat command
F0_pth = [pwd filesep num2str(round(rand(1,1)*1e5)) '.tmp'];
while(exist(F0_pth, 'file'))
    F0_pth = [pwd filesep num2str(round(rand(1,1)*1e5)) '.tmp'];
end

if(strcmp(computer, 'MACI64'))
    cmd = ['/Applications/Praat.app/Contents/MacOS/Praat --run' ' ' ...
        'praat_voicing.praat ' wav_pth ' ' F0_pth ' ' ...
        num2str(minimum_pitch) ' ' num2str(maximum_pitch)];
else
    cmd = [dir_pth 'praatcon.exe' ' ' dir_pth 'praat_voicing.praat ' ...
    wav_pth ' ' F0_pth ' ' num2str(minimum_pitch) ' ' ...
    num2str(maximum_pitch)];
end

stat = system(cmd);

%% Load data to the environment
F0 = [];
if(~stat)
    fid = fopen(F0_pth, 'r');
    F0 = textscan(fid, '%f', 'HeaderLines', 4);
    F0 = F0{1,1};
    fclose(fid);
end

delete(F0_pth);
delete(wav_pth);

%% Set F0 to the binary values
sel = F0 >= minimum_pitch;
F0(sel) = 1;
F0(~sel) = 0;

%% Get the voicing vector
if(n_seg > 0)
    tmp = fix(linspace(1,length(F0),n_seg));
    F0 = F0(tmp);
end

vo = logical(F0);