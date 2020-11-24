%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                            %
%      Atmospheric attenuation calculation   %
%                     From:                  %
% Computing the absorption of sound by the   %
%    atmosphere and its applicability to     %
%        aircraft noise certification.       %
%           by Edward J Rickley              %
%                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%temp = temperature in Celcius
%humidity = relative humidity in %
function [alfa] = atmatt_single(freq,temp,humidity)
T = temp+273.15;
hrel = humidity;
f = freq; %frequencies in Hz
Pa = 101.325;
Pr = 101.325; %ref pressure kPa
Tr = 293.15; %ref temp
T01 = 273.15; %
V = 10.79583*(1-(T01/T))-5.02808*log10(T/T01)+1.50474*10^(-4)*(1-10^(-8.29692*((T/T01)-1)))+0.42873*10^(-3)*(-1+10^(4.76955*(1-(T01/T))))-2.2195983;
Psat = Pr*10^V;
h = hrel*(Psat/Pr)*(Pa/Pr)^-1;
Fro = (Pa/Pr)*(24+((4.04*10^4*h)*(0.02+h)/(0.391+h)));
FrN = (Pa/Pr)*sqrt(T/Tr)*(9+280*(h)*exp(-4170*((T/Tr)^(-1/3)-1)));

alfa = 8.686*f.^2*((1.84*10^(-11)*(Pa/Pr)^(-1)*sqrt(T/Tr))+(T/Tr)^(-5/2)*(0.01275*exp(-2239.1/T)*(Fro/(Fro^2+f.^2))+0.1068*(exp(-3352.0/T))*(FrN/(FrN^2+f.^2))));


end