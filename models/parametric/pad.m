% This program is part of the reproducible research materials added to 
% the Chapter "Application of Dynamic Features of the Pupil for Iris 
% Presentation Attack Detection" to appear in Sebastien Marcel, Mark 
% Nixon, Julian Fierrez, Nicholas Evans, "Handbook of Biometric 
% Anti-Spoofing (2nd Edition)"
%
% It is licensed under a Creative Commons Attribution 3.0 Unported License 
% (see http://creativecommons.org/licenses/by/3.0/).
%
% Please provide the following reference when using these materials: 
% Adam Czajka and Benedict Becker, "Application of Dynamic Features of the 
% Pupil for Iris Presentation Attack Detection" in Sebastien Marcel, Mark 
% Nixon, Julian Fierrez, Nicholas Evans, "Handbook of Biometric 
% Anti-Spoofing (2nd Edition)", http://zbum.ia.pw.edu.pl/EN/node/22
% 
% (c) Adam Czajka, September 2017, www.adamczajka.pl

clear all
close all

%% Global parameters
argsLive.FPS = 25;          % frames per second
argsLive.EXPTIME = 5000;    % in this example we use 5s (5000ms) time series
argsSpoof.FPS = 25;          
argsSpoof.EXPTIME = 5000;   

% load an example "authentic" pupil dynamics time series 
% (exceprt from Warsaw-BioBase-Pupil-Dynamics v2.1 database):
% measurements for the right eye of subject 85 in session 2
tab = readtable('Warsaw-BioBase-Pupil-Dynamics-v2.1-excerpt.csv');
ind = ...
    ismember(tab.SUBJECT_ID,85) & ...
    ismember(tab.EYE,'R') & ...
    ismember(tab.SESSION,2);
tab_data = tab.PUPIL_RADIUS_DENOISED_NORMALIZED(ind,:);

% Positive stimuli appears after 15 seconds in this sample 
% (i.e., frame = 376) and lasts 5 seconds (i.e., 125 frames)
argsLive.seqX = 1:125;
signalY = tab_data(376:501);
argsLive.seqY = signalY-signalY(1);


% now load an example "spoof" pupil dynamics time series, that is the 
% measurements of the pupil size without light stimulation; this time
% take the data for the left eye of subject 1 in session 1
ind = ...
    ismember(tab.SUBJECT_ID,1) & ...
    ismember(tab.EYE,'L') & ...
    ismember(tab.SESSION,1);

tab_data = tab.PUPIL_RADIUS_DENOISED_NORMALIZED(ind,:);

% and select, for instance, pupil size recorded between the 1-st 
% (frame = 25) and the 6-th (frame = 150) second
argsSpoof.seqX = 1:125;
signalY = tab_data(25:150);
argsSpoof.seqY = signalY-signalY(1);


%% Clynes-Kohn model identification

% starting point
% T1 = p(1);
% T2 = p(2);
% T3 = p(3);
% tau1 = p(4);
% tau2 = p(5);
% Kr = p(6);
% Ki = p(7);
p0 = [0.25 0.25 0.4 0.28 0.35 1 1]; % taken from the original Clynes' paper, except the gains

% lower bounds
p0lb = zeros(1,7);

% upper bounds
p0ub = [25 25 40 28 35 100 100];

% solver options
options = optimoptions('lsqnonlin');
options.Algorithm = 'trust-region-reflective';
options.Diagnostics = 'off';
options.Display = 'off'; %'final-detailed';
options.MaxIter = 10000;
options.MaxFunEvals = 10000;
options.FinDiffType = 'central';
options.FunValCheck = 'on';
options.TolX = 1e-5;
options.TolFun = 1e-5;

% identify the model parameters for "live" time series
model_live = lsqnonlin(@fitErrorLight,p0,p0lb,p0ub,options,argsLive);

% identify the model parameters for "spoof" time series
model_spoof = lsqnonlin(@fitErrorLight,p0,p0lb,p0ub,options,argsSpoof);


%% Classification

% load trained SVM for positive, 5s ligth stimuli 
load('./trained_svm/parametric_SVMrbf_light_5s','svmStruct');

% classification result for "live" sample:
if (svmclassify(svmStruct, model_live) == 1)
    disp('Live')
else
    disp('Spoof')
end

% classification result for "spoof" sample:
if (svmclassify(svmStruct, model_spoof) == 1)
    disp('Live')
else
    disp('Spoof')
end