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

tab = readtable('../scores/scores_fig12.csv');

STIMULUS{1} = 'light';
STIMULUS{2} = 'dark';

VARIANT_CSV{1} = 'SVMlinear';
VARIANT_FIG{1} = 'SVM (linear)';

VARIANT_CSV{2} = 'kNN1';
VARIANT_FIG{2} = 'kNN (k=1)';

EXPTIME = 1600:200:5000;

%% Calculate APCER and BPCER from 1.6 to 5 sec horizons (every 200 ms)
for i=1:2
    
    for s=1:length(EXPTIME)
        
        % APCER
        ind = ...
            ismember(tab.Variant,char(VARIANT_CSV{i})) & ...
            ismember(tab.Stimulus,char(STIMULUS{i})) & ...
            ismember(tab.Milliseconds,EXPTIME(s)) & ...
            ismember(tab.Label,0);
        
        tab_data = tab(ind,:);
        APCER(i,s) = abs(sum(tab_data.Score) / height(tab_data));
        
        % BPCER
        ind = ...
            ismember(tab.Variant,char(VARIANT_CSV{i})) & ...
            ismember(tab.Stimulus,char(STIMULUS{i})) & ...
            ismember(tab.Milliseconds,EXPTIME(s)) & ...
            ismember(tab.Label,1);
        
        tab_data = tab(ind,:);
        BPCER(i,s) = (1-abs(sum(tab_data.Score) / height(tab_data)));
          
    end
end

%% Plot figures
x = 1:length(EXPTIME);

for i = 1:2
    
    figure(i)
    
    hold on
    set(gca,'FontSize',20)
    axis([0 length(EXPTIME)+1 0 2])
    
    pFRR = polyfit(x,100*BPCER(i,:),1);
    pFAR = polyfit(x,100*APCER(i,:),1);
    
    axis([0 length(EXPTIME)+1 0 4])
    set(plot(100*BPCER(i,:),'b.'),'MarkerSize',30)
    set(plot(100*APCER(i,:),'r*'),'MarkerSize',15)
    set(gca,'XTick',[3 8 13 18],'XTickLabel',[2 3 4 5])
    set(plot(x,pFRR(1)*x+pFRR(2),'b'),'LineWidth',1);
    set(plot(x,pFAR(1)*x+pFAR(2),'r--'),'LineWidth',1);
    xlabel('Observation time (sec)')
    ylabel('Estimated error rates (%)')
    title(char(VARIANT_FIG{i}))
    legend('BPCER','APCER','Regression for BPCER','Regression for APCER')
    grid on
    hold off
    
end