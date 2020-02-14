
%%%%%%%%%%%%%%%%%%%%% (D1) Retrieval - Short delay %%%%%%%%%%%%%%%%%%%%%%%%

%%% Information %%%

    % 70 stimuli
    % 50 task trials
    % 20 control trials
    % c.a 15 mins (without pauses)
    % Condition A (ISI TYPE)
    % Condition B (Ja/Nein)
    % Condition C (Stimuli recall)

%%% Design %%%

    % Fixation cross = ISI
    % Presentation   = Room without objects
    % Selection      = Empty room + circle and 3 choices (cue, alternative and external lure)
    % Feedback       = NO
    % Pauses         = 17/34/51 (every 17 trials)

% To stop the script press 't' during selection phase.

clc
clearvars

%% 1. Set paths
path.root    = 'C:\Users\elisa\Documents\MATLAB\Scripts\Placeobject\A_behavioral\';
path.task    = [ path.root 'A_scripts']; %Stimlist is here
path.sti     = 'C:\Users\elisa\Dropbox\PhD\Stimuli\Place_object\A_All_stimuli\';
path.res     = [ path.root 'D_results\'];
path.input   = [ path.root 'B_inputfiles\'];
path.config  = [ path.root 'C_ISIfiles\'];
path.ptb   =  'C:/Users/elancini/Documents/MATLAB/Psychtoolbox/';% Path PTB
path.gstreamer= 'C:\gstreamer\1.0\x86_64\bin';
addpath(genpath(path.ptb));

%% 2. Subject infos

% Subject informations
input_prompt = {'Participant number'; 'Condition A'; 'Condition B';'Condition C';'Session (1= prac.Enc / 2= enc / 3= prac.Retr short / 4=retr short / 5= prac.Retr long / 6= Retr long)'};
input_defaults     = {'01','1','1','1','99'}; % Mostra input default per non guidare l'inserimento
input_answer = inputdlg(input_prompt, 'Informations', 1, input_defaults);
clear input_defaults input_prompt
%Modifiy class of variables
ID          = str2num(input_answer{1,1});
ConditionA  = str2num(input_answer{2,1}); % ISI randomization
ConditionB  = str2num(input_answer{3,1}); % Yes no counterbalancing
ConditionC  = str2num(input_answer{4,1}); % Stimuli to present from encoding session
Session     = str2num(input_answer{5,1});

% Check if is the experimenter is using the right script
if Session ~= 4
    errordlg('You are running the wrong script','Session error');
    return
end

% Check if Conditions are >1 and <2 , otherwise error will occur

if ConditionA > 2 || ConditionB > 2 || ConditionC > 2 || ConditionA == 0 || ConditionB == 0||ConditionC == 0
    errordlg('Condition does not eist, check','Condition error');
    return
end

% Check if data already exist
cd(path.res)
if exist([num2str(ID) '_' num2str(Session) '_randinfo.mat']) == 2
    check_prompt = {'(1) Append a "r" / (2) Overwrite /(3) Break'};
    check_defaults     = {'1'}; % default input
    check_answer = inputdlg(check_prompt, 'No bueno', 1, check_defaults);
    check_decision= str2double(check_answer); % Depending on the decision..
    if check_decision == 1
        ID= [num2str(ID) '_R']; %append r to filename
    elseif check_decision == 3  %break
        return;
    end
end

%% 3. Load settings
cd(path.input)
Settings_retrieval;

%% 4. Pre allocate

stimuli_list_ordered= cell(1,7); %Stimuli sorted by ITI order

response_key=zeros(numTrials,1);
response_key_question=zeros(numTrials,1);
response_time=zeros(numTrials,1);
response_time_question=zeros(numTrials,1);
response_kbNum=zeros(numTrials,1);
response_kbNum_question=zeros(numTrials,1);

idx=[]; %Index of cue
time_pause=zeros(1,70);
time_end=999;
events=cell(1,2);

%% 5. Load stimuli list from encoding session
%load stimuli_list_ordered in the encoding session
cd(path.res)
load([num2str(ID) '_2_' 'randinfo'],'rows_rand1');
load([num2str(ID) '_2_' 'randinfo'],'rows_rand2');
load([num2str(ID) '_2_' 'randinfo'],'stimuli_list');
stimuli_list_encoding=stimuli_list;
rows_rand1_encoding=num2cell(rows_rand1);
rows_rand2_encoding=num2cell(rows_rand2);

clear rows_ordered stimuli_list_ordered stimuli_list rows_rand1 rows_rand2

%% Cerca in rows rand gli 1 e gli 0

% trova la riga in cui gli stimoli del primo blocco sono andate a finire
A1_ones_rows=(1:50);  %Prima parte
A1_zeros_rows=(1:20);

A2_ones_rows=(1:50);  %Seconda parte (altra met?)
A2_zeros_rows=(1:20);

for x=1:50
%     A1_ones_rows(x)=find([rows_rand1_encoding{:,1}] == x);
    A1_ones_rows(x)=(rows_rand1_encoding{x,1});
    A2_ones_rows(x)=(rows_rand2_encoding{x,1});
end
 
for x=1:20
%     A1_zeros_rows(x)=find([rows_rand1_encoding{:,1}] == (x+50));
    A1_zeros_rows(x)=(rows_rand1_encoding{x+50,1});
    A2_zeros_rows(x)=(rows_rand2_encoding{x+50,1});
end

% Crea parte A , divisa in due e parte B (altra met?) divisa in due
A1_1= [A1_ones_rows(1:25) A1_zeros_rows(1:10)];
A1_2= [A1_ones_rows(26:50) A1_zeros_rows(11:20)];

B1_1= [A2_ones_rows(1:25) A2_zeros_rows(1:10)];
B1_2= [A2_ones_rows(26:50) A2_zeros_rows(11:20)];


% Unifica
    if ConditionC==1
        list=[A1_1 B1_2];
    elseif ConditionC==2
         list=[A1_2 B1_1];
    end
    
%% Build up the stimuli list based on the indices
% and randomize it at the same time

stimuli_list= cell(1,7);

rows=(1:numTrials); %From1 to 70
rows_rand=rows(randperm(length(rows)))'; % Randomize the order

for n= 1:numTrials
    x=list(n); %from the encoding list, pick up the element selcted...
    y=rows_rand(n); %and put it in this randomized position
 stimuli_list{1, 1}{y, 1} = stimuli_list_encoding{1, 1}{x, 1};
 stimuli_list{1, 2}{y, 1} = stimuli_list_encoding{1, 2}{x, 1};  
 stimuli_list{1, 3}{y, 1} = stimuli_list_encoding{1, 3}{x, 1};  
 stimuli_list{1, 4}{y, 1} = stimuli_list_encoding{1, 4}{x, 1};  
 stimuli_list{1, 5}{y, 1} = stimuli_list_encoding{1, 5}{x, 1};  
 stimuli_list{1, 6}{y, 1} = stimuli_list_encoding{1, 6}{x, 1}; % trial ype
 stimuli_list{1, 7}{y, 1} = stimuli_list_encoding{1, 7}{x, 1}; % cue type
end

clear rows_num rows_ordered_encoding_* first_part* second_part* pos_1 pos_2 n x y type x n

%% ---------- Create matrix of stimuli depending on ISI trialtype ------- %

%  Load ITI
cd(path.config);

if ConditionA ==1
    load('ISI_OA_retr_1.mat');
elseif ConditionA ==2
    load('ISI_OA_retr_2.mat');
elseif exist(ConditionA,'var')== 0
    check_conditionA = {'Please specify condition A'};
    check_defaults     = {'1'}; % default input
    check_answer = inputdlg(check_conditionA, 'No condition specified !', 1, check_defaults);
    ConditionA= str2double(check_answer); % Depending on the decision..
    if ConditionA ==1
        load('ISI_OA_retr_1.mat');
    elseif ConditionA ==2
        load('ISI_OA_retr_2.mat');
    end
end
trial_type_ISI = design_struct.eventlist(:, 3);
ISI= design_struct.eventlist(:, 4); %PTB uses seconds
trial_type=stimuli_list{1,6};
%find where are trial stimuli and control stimuli
indexones = find([trial_type{:}] == 1)';
indexzeros = find([trial_type{:}] == 0)';
% recreate a stimuli list based in ITI.
indexones_ITI= find(trial_type_ISI==1);
indexzeros_ITI= find(trial_type_ISI==0);
% create list of stimuli


% replace rows

for i = 1:20 % first block
    m = indexzeros_ITI(i); %new position of the '0' stimuli (position ITI)
    n = indexzeros(i);% old position of the '0' stimuli
    stimuli_list_ordered{1,1}(m,1)=stimuli_list{1,1}(n,1);
    stimuli_list_ordered{1,2}(m,1)=stimuli_list{1,2}(n,1);
    stimuli_list_ordered{1,3}(m,1)=stimuli_list{1,3}(n,1);
    stimuli_list_ordered{1,4}(m,1)=stimuli_list{1,4}(n,1);
    stimuli_list_ordered{1,5}(m,1)=stimuli_list{1,5}(n,1);
    stimuli_list_ordered{1,6}(m,1)=stimuli_list{1,6}(n,1);
    stimuli_list_ordered{1,7}(m,1)=stimuli_list{1,7}(n,1);
end

for ii = 1:50 %first block
    m = indexones_ITI(ii); %new position of the '1' stimuli (position ITI)
    n = indexones(ii); %old position of the '1' stimuli
    stimuli_list_ordered{1,1}(m,1)=stimuli_list{1,1}(n,1);
    stimuli_list_ordered{1,2}(m,1)=stimuli_list{1,2}(n,1);
    stimuli_list_ordered{1,3}(m,1)=stimuli_list{1,3}(n,1);
    stimuli_list_ordered{1,4}(m,1)=stimuli_list{1,4}(n,1);
    stimuli_list_ordered{1,5}(m,1)=stimuli_list{1,5}(n,1);
    stimuli_list_ordered{1,6}(m,1)=stimuli_list{1,6}(n,1);
    stimuli_list_ordered{1,7}(m,1)=stimuli_list{1,7}(n,1);
end

indexpast=[indexzeros ; indexones];
indexnew=[indexzeros_ITI ; indexones_ITI];

for n= 1:70
whereitwas=indexpast(n);
stimname=stimuli_list{1, 1}{whereitwas, 1};
whereininput=find(stimname==inputfile);
ITI_list(whereininput,1)=indexnew(n);
end


% ---------- Randomize stimuli position on the screen ------- %

% Monitor
[windowPtr,rect]=Screen('OpenWindow',0,backgroundColor);
slack = Screen('GetFlipInterval', windowPtr)/2; %Calcola quanto tempo ci sta a flippare lo schermo (serve poi per il calcolo del tempo di present)
% rect=Screen('Rect', 0,0); %Comment this if you want to refer to small size monitor, let it code if you want to refer to full monitor
% Display variables
xMax=rect(1,3);
yMax=rect(1,4);
xCenter= xMax/2;
yCenter= yMax/2;
% Coordinates
topcentral=[xCenter-(picWidth/2), gap, xCenter+(picWidth/2), gap+picHeight];
pos_central= [ xCenter-(objpicWidth/2), gap+picHeight+gapHeight, xCenter+(objpicWidth/2), gap+picHeight+gapHeight+objpicHeight];
pos_left= [topcentral(1,1),  gap+picHeight+gapHeight, topcentral(1,1)+objpicWidth , gap+picHeight+gapHeight+objpicHeight];
pos_right= [topcentral(1,3)-objpicWidth,  gap+picHeight+gapHeight, topcentral(1,3) , gap+picHeight+gapHeight+objpicHeight];
% Randomize coordinates of choices on the screen
stimuli_choice_pos= cell(1,3);
where={pos_left,pos_central, pos_right};
for x=1:(numTrials)
    stimuli_choice_pos(x,:)=Shuffle(where);
end

clear x

%% 7. Save randomization information
 save([path.res num2str(ID) '_' num2str(Session) '_randinfo.mat']);
%% TASK
% try
    %% ------ Welcome screen ------ %
    Screen('TextSize', windowPtr,50);               %Set text size
    Screen('TextFont', windowPtr,'Helvetica');      %Set font
    Screen('TextStyle', windowPtr,4);               %Set style
    line1='Willkommen zum Experiment';              %Set text, location (xy)and color
    line2='\n';
    line3='\n\n Drucken Sie die Leertaste, um zu starten';
    DrawFormattedText(windowPtr,[line1 line2 line3], 'center','center', textColor);    %Show the results on the screen
    Screen('Flip', windowPtr);
    %Wait untile spacebar is pressed
    while 1
        [keyIsDown,secs,keyCode] = KbCheck;
        if keyCode(KbName('SPACE'))==1
            break
        end
    end
    
    t_last_onset(1)=secs;

    %% ------ Stimuli presentation ------ %
        
    startscript=tic; %start couting the time for completing the entire task
    
    for i = 1:numTrials
        fixation_duration=ISI(i);
        % ---------- Fixation cross ---------- %
        crossLines= [-crossLenght, 0 ; crossLenght, 0; 0 , -crossLenght; 0, crossLenght];
        crossLines= crossLines';
        Screen('DrawLines', windowPtr, crossLines, crossWidth, crossColor, [xCenter, yCenter]);
        t_fixation_onset(i)=Screen('Flip',windowPtr,  t_last_onset(i)-slack);
        t_fixation_offset(i)=Screen('Flip',windowPtr,t_fixation_onset(i)+fixation_duration-slack);        
        % ---------------- Cue ---------------- %
        pic_cue=imread([path.sti stimuli_list_ordered{1, 2}{i, 1}], 'png');
        pic_cue_texture=Screen('MakeTexture', windowPtr, pic_cue);
        Screen('DrawTexture', windowPtr, pic_cue_texture, [], topcentral);
        t_cue_onset(i)= Screen('Flip', windowPtr, t_fixation_offset(i)-slack); % show image
        t_cue_offset(i)=Screen('Flip', windowPtr, t_cue_onset(i)+ cue_duration-slack); % show image
        % ---------------- Question "Were there objects?" ---------------- %
        Screen('TextSize', windowPtr,50);
        Screen('TextFont', windowPtr,'Helvetica');
        Screen('TextStyle', windowPtr,4);
        % Draw text
        line1='Enthielt der Raum Objekte?';
        line2='\n';
        if ConditionB==1
            line3='\n\n Ja      Nein';
        elseif ConditionB==2
            line3='\n\n Nein      Ya';
        end
        DrawFormattedText(windowPtr,[line1 line2 line3], 'center','center', textColor);
        t_classification_onset(i)= Screen('Flip', windowPtr, t_cue_offset(i)-slack);
        %Record response
        FlushEvents('keyDown')
        t1 = GetSecs;
        time = 0;
        while time < classification_timeout
            [keyIsDown,t2,keyCode] = KbCheck; %determine state of keyboard
            time = t2-t1 ;
            if (keyIsDown) %has a key been pressed?
                key = KbName(find(keyCode));
                type= class(key);
                if type == 'cell' %If two keys pressed simultaneously, then 0
                    response_key_question(i,1)= 99;
                    response_kbNum_question(i,1)= 99;
                    response_time_question(i,1)=99;
                elseif key== 'a'
                    response_key_question(i,1)= 1; %if a was pressed, 1
                    response_time_question(i,1) =time;
                    response_kbNum_question(i,1)=  find(keyCode);
                elseif key == 'l'
                    response_key_question(i,1) =2; %if l was pressed, 2
                    response_time_question(i,1) =time;
                    response_kbNum_question(i,1)=  find(keyCode);
                elseif key == 't'
                    events{1, 1}= 'Script aborted' ;
                    events{1, 2}= i ;
                    events{1, 3}= toc(startscript) ;
                    sca %A red error line in the command window will occur:  "Error using Screen".
                end
            end
        end
        t_classification_offset(i)= Screen('Flip', windowPtr, t_classification_onset(i)+classification_timeout-slack);
        % ---------------- Selection ---------------- %
        % Select which picture to read
        pic_alt1=imread([path.sti stimuli_list_ordered{1, 3}{i, 1}], 'jpg'); % object
        pic_alt2=imread([path.sti stimuli_list_ordered{1, 4}{i, 1}], 'jpg'); % internal lure
        pic_lure=imread([path.sti stimuli_list_ordered{1, 5}{i, 1}], 'jpg'); % external lure
        %Make textures of them
        pic_alt1_texture=Screen('MakeTexture', windowPtr, pic_alt1);
        pic_alt2_texture=Screen('MakeTexture', windowPtr, pic_alt2);
        pic_lure_texture=Screen('MakeTexture', windowPtr, pic_lure);
        % Put them toghtether (....if you want to present them in the same screen)
        pics=[pic_cue_texture pic_alt1_texture pic_alt2_texture pic_lure_texture]';
        % Concatenate position of the pics
        positions=[topcentral' , stimuli_choice_pos{i, 1}' , stimuli_choice_pos{i, 2}' , stimuli_choice_pos{i, 3}'];
        % Flip (draw all toghether)
        Screen('DrawTextures', windowPtr, pics, [], positions);
        t_selection_onset(i)= Screen('Flip', windowPtr,  t_classification_offset(i)-slack);        
        %Record response
        FlushEvents('keyDown')
        t1 = GetSecs;
        time = 0;
        while time < selection_timeout
            [keyIsDown,t2,keyCode] = KbCheck; %determine state of keyboard
            time = t2-t1 ;
            if (keyIsDown) %has a key been pressed?
                key = KbName(find(keyCode));
                type= class(key);
                if type == 'cell' %If two keys pressed simultaneously, then 0
                    response_key(i,1)= 99;
                    response_kbNum(i,1)= 99;
                    response_time(i,1)= 99;
                elseif key== 'a'
                    response_key(i,1)= 1; %if a was pressed, 1
                    response_time(i,1) =time;
                    response_kbNum(i,1)= find(keyCode);
                elseif key == 'space'
                    response_key(i,1)= 2; %if space was pressed, 2
                    response_time(i,1) =time;
                    response_kbNum(i,1)= find(keyCode);
                elseif key == 'l'
                    response_key(i,1) =3; %if l was pressed, 2
                    response_time(i,1) =time;
                    response_kbNum(i,1)= find(keyCode);
                elseif key == 't'
                    events{1, 1}= 'Script aborted' ;
                    events{1, 2}= i ;
                    events{1, 3}= toc(startscript) ;
                    sca %A red error line in the command window will occur:  "Error using Screen".
                end
            end
        end
        t_selection_offset(i)= Screen('Flip', windowPtr, t_selection_onset(i)+selection_timeout-slack);
        time_lastbackup=toc(startscript);
        t_last_onset(i+1)=t_selection_offset(i); 

        % Backup of answers after every keypressed
         save([path.res num2str(ID) '_' num2str(Session) '_backup.mat']);        
        
        % ------------- ???? Pause ??? -------------%
        %After half of the trials, pause.
        if i == breakAfterTrials1 || i==breakAfterTrials2 || i==breakAfterTrials3
            Screen('TextSize', windowPtr,50);               %Set text size
            Screen('TextFont', windowPtr,'Helvetica');      %Set font
            Screen('TextStyle', windowPtr,4);               %Set style
            if i == breakAfterTrials1 || i == breakAfterTrials2 || i == breakAfterTrials3 || i == breakAfterTrials4 || i == breakAfterTrials5 || i == breakAfterTrials6
                line1='Sie konnen eine Pause machen';              %Set text, location (xy)and color
            elseif i== breakAfterHalfTrials
                line1='Die Halfte des Experiments ist abgeschlossen.';              %Set text, location (xy)and color
            end
            line2='\n';
            line3='\n\n Drucken Sie die Leertaste, um zu starten';
            DrawFormattedText(windowPtr,[line1 line2 line3], 'center','center', textColor);    %Show the results on the screen
            t_pause_onset(i)= Screen('Flip', windowPtr); % show image
            startpause=tic; % start counting the seconds of pause
            %Wait untile spacebar is pressed
            while 1
                [keyIsDown,secs,keyCode] = KbCheck;
                if keyCode(KbName('SPACE'))==1
                    break
                end
            end
            time_pause(i)=toc(startpause); % how many seconds of pause did the participant take?
            clear tic % so it doesn't interfere with the main tic
            t_pause_offset(i)=t_pause_onset(i)+secs-slack; %variable that in the loop becames the feedback timestamp
        end   
    end
    
    time_end=toc(startscript); %calculate time for completing entire task
    
    
    %%  -------- End screen -------- %
    Screen('TextSize', windowPtr,50); %Set text size
    Screen('TextFont', windowPtr,'Helvetica'); %Set font
    Screen('TextStyle', windowPtr,4); %Set style
    line1='Das Experiment ist beendet';
    line2='\n';
    line3='\n\n Vielen Dank fur Ihre Teilnahme';
    DrawFormattedText(windowPtr,[line1 line2 line3], 'center','center', textColor);
    t_end_onset=Screen('Flip', windowPtr);     %Show the results on the screen
    t_end_offset=Screen('Flip', windowPtr,t_end_onset(end)+5-slack);     %Show the results on the screen
    sca %Close all
    
    %% 8. Re enable keyboard
    RestrictKeysForKbCheck;
    ListenChar(0);
    
    %% 9. Save before analysis
    
     save([path.res num2str(ID) '_' num2str(Session) '_raw.mat']);
    
    %% 10. Analyze answers
    
    % Find pictures real position
    % cue, alternative, external lure
    % 1=left, 2=center, 3= right
    stimuli_choice_pos_coded=[1,1];
    for c=1:3
        for r = 1:numTrials
            position=stimuli_choice_pos{r,c};
            if position(1) == pos_left(1,1)
                stimuli_choice_pos_coded(r,c)= 1;
            elseif position(1) == pos_central(1,1)
                stimuli_choice_pos_coded(r,c)= 2;
            elseif position(1) == pos_right(1,1)
                stimuli_choice_pos_coded(r,c)= 3;
            end
        end
    end
    
    % Find correct answers and errors for choices
    answers=strings(numTrials,1);
    for r=1:length(response_key)
        if ismember(response_key(r),stimuli_choice_pos_coded(r,1)) == 1 %cue column
            answers(r,1)= "T"; %Correct answers
        elseif ismember(response_key(r),stimuli_choice_pos_coded(r,2)) == 1 %internal lure colums
            answers(r,1)= "IL"; %Internal lure
        elseif ismember(response_key(r),stimuli_choice_pos_coded(r,3)) == 1 %external lure column
            answers(r,1)= "EL"; %External lure
        elseif response_key(r) == 0
            answers(r,1)= "no response"; %no response was made
        elseif response_key(r) == 99
            answers(r,1)= "multiple response"; % multiple response were made
        end
    end
    
    % Find correct answer to room classification
    answers_classification=strings(numTrials,1);
    for r=1:length(response_key)
        
        if ConditionB ==1
            ja = 1;
            nein = 2;
        elseif ConditionB ==2
            ja= 2;
            nein=1;
        end
        % response_key_question 1 = Ja, 2 = Nein
        % stimuli_list{1, 6}(r, 1), 1 = Task, 0= Control
        
        if response_key_question(r) == ja && stimuli_list_ordered{1, 6}{r, 1} == 1
            answers_classification(r,1)= "tT"; %Correct answer for task trial
        elseif response_key_question(r) == nein && stimuli_list_ordered{1, 6}{r, 1} == 1
            answers_classification(r,1)= "tF"; %Wrong answer for task trial
        elseif response_key_question(r) == nein && stimuli_list_ordered{1, 6}{r, 1} == 0
            answers_classification(r,1)= "cT"; %Correct answer for task trial
        elseif response_key_question(r) == ja && stimuli_list_ordered{1, 6}{r, 1} == 0
            answers_classification(r,1)= "cF"; %Wrong answer for control trial
            
        elseif response_key_question(r) == 99 && stimuli_list_ordered{1, 6}{r, 1} == 1
            answers_classification(r,1)= "multiple response T"; %Wrong answer for control trial
        elseif response_key_question(r) == 99 && stimuli_list_ordered{1, 6}{r, 1} == 0
            answers_classification(r,1)= "multiple response C"; %Wrong answer for control trial
            
        elseif response_key_question(r) == 0 && stimuli_list_ordered{1, 6}{r, 1} == 1
            answers_classification(r,1)= "no response T"; %Wrong answer for control trial
        elseif response_key_question(r) == 0 && stimuli_list_ordered{1, 6}{r, 1} == 0
            answers_classification(r,1)= "no response C"; %Wrong answer for control trial
        end
        
    end
    
    %% 11. Resume
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% Classification %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Total results
    resultsClass.hintsTrial=sum(answers_classification=="tT");
    resultsClass.hintsControl=sum(answers_classification=="cT");
    
    resultsClass.errorsTrial=sum(answers_classification=="tF");
    resultsClass.errorsControl=sum(answers_classification=="cF");
    
    resultsClass.missedTrial=sum(answers_classification=="no response T");
    resultsClass.missedControl=sum(answers_classification=="no response C");
    
    resultsClass.multipleTrial=sum(answers_classification=="multiple response T");
    resultsClass.multipleControl=sum(answers_classification=="multiple response C");
    
    resultsClass.totalresponseTrial=sum(resultsClass.hintsTrial+resultsClass.errorsTrial); %T+IL+E
    resultsClass.totalresponseControl=sum(resultsClass.hintsControl+resultsClass.errorsControl); %T+IL+E
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% Selection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Total results
    results.hints=sum(answers=="T");
    results.falseallarm=sum(answers=="IL");
    results.errors=sum(answers=="EL");
    results.missed=sum(answers=="no response");
    results.multiple=sum(answers=="multiple response");
    results.totalresponse=sum(results.hints+results.falseallarm+results.errors); %T+IL+E
    
    % Trial related results (task trial (1) /control trial (0))
    for i = 1:numTrials
        
        if stimuli_list_ordered{1, 6}{i, 1} == 1
            taskanswers(i,1)= answers(i,1)   ;
             controlanswers(i,1) = "control trial"   ; %if it is not 
        else
            controlanswers(i,1) = answers(i,1)   ;
             taskanswers(i,1)= "task trial"    ;           
        end
    end
    
    % Total results
    results.hints_1=sum(taskanswers=="T");
    results.falseallarm_1=sum(taskanswers=="IL");
    results.errors_1=sum(taskanswers=="EL");
    results.missed_1=sum(taskanswers=="no response");
    results.multiple_1=sum(taskanswers=="multiple response");
    results.totalresponse_1=sum(results.hints_1+results.falseallarm_1+results.errors_1);
    
    results.hints_0=sum(controlanswers=="T");
    results.falseallarm_0=sum(controlanswers=="IL");
    results.errors_0=sum(controlanswers=="EL");
    results.missed_0=sum(controlanswers=="no response");
    results.multiple_0=sum(controlanswers=="multiple response");
    results.totalresponse_0=sum(results.hints_0+results.falseallarm_0+results.errors_0);
        
    %% 12. Save
    inputfile_creation.encoding_stimuli_list =stimuli_list_encoding;
    inputfile_creation.rows_randomization_encoding1 =rows_rand1_encoding;
    inputfile_creation.rows_randomization_encoding2 =rows_rand2_encoding;
    inputfile_creation.positions_stimuli_to_use= list; 
    
    stimuli.stimuli_randomized= stimuli_list;
    stimuli.row_randomization=rows_rand;  
    stimuli.stimuli_ordered_per_ISI_trialtype= stimuli_list_ordered;  
    stimuli.ISI_trial_type= trial_type_ISI;
    stimuli.choice_position = stimuli_choice_pos;
    stimuli.choice_position_coded = stimuli_choice_pos_coded;

    answer.response_kbNum=response_kbNum;
    answer.response_kbNum_question=response_kbNum_question;    
    answer.response_key  =response_key;
    answer.response_key_question  =response_key_question;
    answer.response_time =response_time;
    answer.response_time_question =response_time_question;
    answer.all_selection_answers   = answers; 
    answer.task_answers = taskanswers;
    answer.control_answers = controlanswers;
    answer.all_classification_answer= answers_classification;

 
    timing.end=(time_end/60); %from seconds to minutes (are now in msec because calculated by Matlab)
    timing.pause=time_pause/60;
    timing.last_backup=time_lastbackup/60;
    timing.ISI=ISI; % Already in seconds        
    timing.fixation_onset=t_fixation_onset; % Already in seconds because calculated by PTB
    timing.fixation_offset=t_fixation_offset;
    timing.cue_onset=t_cue_onset;
    timing.cue_offset=t_cue_offset;
    timing.classification_onset=t_classification_onset;
    timing.classification_offset=t_classification_offset;
    timing.selection_onset=t_selection_onset;
    timing.selection_offset=t_selection_offset;
    timing.end_onset=t_end_onset;
    timing.end_offset=t_end_offset;
    timing.slack=slack;
    
    participant_info.ID=ID;
    participant_info.group_ISI=ConditionA;
    participant_info.group_Ja_Nein=ConditionB;
        
    %% 13. Save results
     save([path.res num2str(ID) '_' num2str(Session) '.mat']...
        , 'participant_info' ...
        , 'stimuli' ...
        , 'results' ... 
        , 'resultsClass'...
        , 'answer' ...
        , 'timing' );
 