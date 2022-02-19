% This program is part of the reproducible research materials added to 
% the Chapter "Application of Dynamic Features of the Pupil for Iris 
% Presentation Attack Detection" to appear in S?bastien Marcel, Mark 
% Nixon, Julian Fierrez, Nicholas Evans, "Handbook of Biometric 
% Anti-Spoofing (2nd Edition)"
%
% It is licensed under a Creative Commons Attribution 3.0 Unported License 
% (see http://creativecommons.org/licenses/by/3.0/).
%
% Please provide the following reference when using these materials: 
% Adam Czajka and Benedict Becker, "Application of Dynamic Features of the 
% Pupil for Iris Presentation Attack Detection" in S?bastien Marcel, Mark 
% Nixon, Julian Fierrez, Nicholas Evans, "Handbook of Biometric 
% Anti-Spoofing (2nd Edition)", http://zbum.ia.pw.edu.pl/EN/node/22
% 
% (c) Adam Czajka, September 2017, www.adamczajka.pl

clear all
close all

tab = readtable('../scores/scores_tab1_parametricSection.csv');

STIMULUS{1} = 'light';
STIMULUS{2} = 'dark';
STIMULUS{3} = 'both';

VARIANT{1} = 'SVMlinear';
VARIANT{2} = 'SVMpolynomial';
VARIANT{3} = 'SVMradial';
VARIANT{4} = 'LogisticRegression';
VARIANT{5} = 'BaggedTrees';
VARIANT{6} = 'kNN1';
VARIANT{7} = 'kNN10';

for r=1:length(STIMULUS)
    for t=1:length(VARIANT)
        
        % APCER
        ind = ...
            ismember(tab.Variant,char(VARIANT{t})) & ...
            ismember(tab.Stimulus,char(STIMULUS{r})) & ...
            ismember(tab.Label,0);
        
        tab_data = tab(ind,:);
        APCER = 100*abs(sum(tab_data.Score) / height(tab_data));
        
        % BPCER
        ind = ...
            ismember(tab.Variant,char(VARIANT{t})) & ...
            ismember(tab.Stimulus,char(STIMULUS{r})) & ...
            ismember(tab.Label,1);
        
        tab_data = tab(ind,:);
        BPCER = 100*(1-abs(sum(tab_data.Score) / height(tab_data)));
        
        disp([char(VARIANT{t}) ' | ' char(STIMULUS{r}) ': APCER = ' num2str(APCER,'%1.2f')  '%, BPCER = ' num2str(BPCER,'%1.2f') '%'])
   
    end
end