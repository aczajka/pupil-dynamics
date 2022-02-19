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

function [x,xUp,xDown] = modelClynesKohnBoth(p,STEPUPinSEC,STEPDOWNinSEC,FPS)
% assumption: the step up comes in t=0

T1 = p(1);
T2 = p(2);
T3 = p(3);
tau1 = p(4);
tau2 = p(5);
Kr = p(6);
Ki = p(7);

xUp = zeros(ceil((STEPUPinSEC+STEPDOWNinSEC)*FPS),1);
xDown1 = zeros(ceil((STEPUPinSEC+STEPDOWNinSEC)*FPS),1);
xDown2 = zeros(ceil((STEPUPinSEC+STEPDOWNinSEC)*FPS),1);

% Modelling step up signals
k=1;
for t = 0:1/FPS:STEPUPinSEC+STEPDOWNinSEC
    if T1==T2
        xUp(k) = -Kr/T1^2*(t-tau1)*exp(-(t-tau1)/T1);
    else
        xUp(k) = Kr/(T2-T1)*(exp(-(t-tau1)/T1)-exp(-(t-tau1)/T2));
    end
    xDown1(k) = -Ki*(1-exp(-(t-tau2)/T3));
    
    k = k + 1;
end

% zero delayed elements
xUp(1:ceil(tau1*FPS)) = 0;
xDown1(1:ceil(tau2*FPS)) = 0;

% Modelling step down signals
k = ceil(STEPUPinSEC*FPS);
for t = 0:1/FPS:STEPDOWNinSEC
    xDown2(k) = Ki*(1-exp(-(t-tau2)/T3));
    
    k = k + 1;
end

% zero delayed elements
xDown2(ceil(STEPUPinSEC*FPS):ceil(STEPUPinSEC*FPS)+ceil(tau2*FPS)) = 0;

% lower channel output
xDown = xDown1(1:ceil((STEPUPinSEC+STEPDOWNinSEC)*FPS)) + xDown2(1:ceil((STEPUPinSEC+STEPDOWNinSEC)*FPS));

% model output
x(1:ceil((STEPUPinSEC+STEPDOWNinSEC)*FPS)) = xUp(1:ceil((STEPUPinSEC+STEPDOWNinSEC)*FPS)) + xDown(1:ceil((STEPUPinSEC+STEPDOWNinSEC)*FPS));