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

function errSum = fitErrorDark(p,args)

%args.EXPTIME
%args.FPS
%args.seqX
%args.seqY

y = modelClynesKohnDark(p,args.EXPTIME/1000,args.FPS);

index = find(args.seqX < ceil(args.EXPTIME*args.FPS/1000)+1);
LENGTH = min(index(end),length(y));
for i=1:LENGTH
    errSum(i) = (args.seqY(i)-y(args.seqX(i)));
end