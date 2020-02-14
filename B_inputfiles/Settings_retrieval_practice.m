%% Settings for experiment (RETRIEVAL)
% Change these to modify main characteristics

%Inizialize variables
response_key = {};
response_time = {};

% Synchronization (2 if in Mac environment, 1 in widonws to disable it. 0 if you want the synchro) 
Screen('Preference','SkipSyncTests', 0);

% Keyboard settings
KbName('UnifyKeyNames');

% Response keys (optional; for no subject response use empty list)
activeKeys = [KbName('a') KbName('space') KbName('l')];

%Pictures dimensions
gap=0; %gap between top of the screen and room
picHeight=600; %measure of room picutures
picWidth=800;
gapHeight= 0; %gap between main room image and choice options (alternative 1, 2 and lure)
objpicHeight=250; %measure of objects
objpicWidth=250;
noiseHeight=900;
noiseWidth=900;

%Fixation cross dimensions
crossLenght = 10;
crossWidth= 3;

% Number of trials
numTrials=5;

% Number of trials to show before a break (for no breaks, choose a number
% greater than the number of trials in your experiment)
breakAfterTrials_encoding = numTrials/2;
breakAfterTrials_retrieval = numTrials/2;

% Background color: choose a number from 0 (black) to 255 (white)
backgroundColor = 0;

% Text color: choose a number from 0 (black) to 255 (white)
textColor = 255;
crossColor = 255;

% How long (in seconds) each image in the RETRIEVAL task will stay on screen
cue_duration = 4.5; %3500 in young, 4500 msec in old
classification_timeout= 3; 
selection_timeout = 5; %3000 msec = meno di 4500
fixation_duration = 2.5; 

% Timeout settings
RestrictKeysForKbCheck(activeKeys);
ListenChar(2); % suppress echo to the command line for keypresses (https://de.mathworks.com/matlabcentral/answers/310311-how-to-get-psychtoolbox-to-wait-for-keypress-but-move-on-if-it-hasn-t-recieved-one-in-a-set-time)


