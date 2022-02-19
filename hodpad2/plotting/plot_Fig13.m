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

tab = readtable('../scores/scores_fig13.csv');

STIMULUS{1} = 'light';
STIMULUS{2} = 'dark';

VARIANT_CSV{1} = 'classicLSTM';
VARIANT_FIG{1} = 'LSTM (no peepholes)';

VARIANT_CSV{2} = 'RNN';
VARIANT_FIG{2} = 'Basic RNN';

EXPTIME = 2:5;

%% Calculate APCER and BPCER for 2, 3, 4 and 5 sec horizons
for i=1:2
    
    for s=1:length(EXPTIME)
        
        % APCER
        ind = ...
            ismember(tab.Variant,char(VARIANT_CSV{i})) & ...
            ismember(tab.Stimulus,char(STIMULUS{i})) & ...
            ismember(tab.Seconds,EXPTIME(s)) & ...
            ismember(tab.Label,0);
        
        tab_data = tab(ind,:);
        APCER(i,s) = abs(sum(tab_data.Node0 < tab_data.Node1) / height(tab_data));
        
        % BPCER
        ind = ...
            ismember(tab.Variant,char(VARIANT_CSV{i})) & ...
            ismember(tab.Stimulus,char(STIMULUS{i})) & ...
            ismember(tab.Seconds,EXPTIME(s)) & ...
            ismember(tab.Label,1);
        
        tab_data = tab(ind,:);
        BPCER(i,s) = (1-abs(sum(tab_data.Node0 < tab_data.Node1) / height(tab_data)));
                
    end
    
end

%% Plot figures
for i = 1:2
    
    figure(i)
    hold on
    set(gca,'FontSize',20)
    
    pFRR = polyfit(EXPTIME,100*BPCER(i,:),1);
    pFAR = polyfit(EXPTIME,100*APCER(i,:),1);
    
    axis([1.5 5.2 0 4])
    set(plot(EXPTIME,100*BPCER(i,:),'b.'),'MarkerSize',30)
    set(plot(EXPTIME,100*APCER(i,:),'r*'),'MarkerSize',15)
    set(gca,'XTick',[2 3 4 5],'XTickLabel',[2 3 4 5])
    set(plot(EXPTIME,pFRR(1)*EXPTIME+pFRR(2),'b'),'LineWidth',1);
    set(plot(EXPTIME,pFAR(1)*EXPTIME+pFAR(2),'r--'),'LineWidth',1);
    xlabel('Observation time (sec)')
    ylabel('Estimated error rates (%)')
    title(char(VARIANT_FIG{i}))
    legend('BPCER','APCER','Regression for BPCER','Regression for APCER')
    set(line([0 length(EXPTIME)],[0 0]),'LineStyle',':','Color','k');
    grid on
    hold off
    
end


