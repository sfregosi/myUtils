
function [click1]=MakePorpoiseClick(Startf, Endf, t, NoiseLevel, SR)

%%%%%%Example input for a porpoise click%%%%%
% NoiseLevel=0.0; %Generally 0->1
% t= 0.0001; %Click Length
% Startf= 135000;  %Start Click Frequency
% Endf=135000; %End Click Frequency
% SR= 500000; %Sample Rate


%make Click
L=0:(t * SR);

%instananeous frequency
f=zeros(L,1);
f(1)=Startf;
tic
%make a series of datapoints the changing frequancy per bin
for i=2:length(L)
    Increment=(Endf-Startf)/length(L);
    f(i)=f(i-1)+Increment;
end
toc
tic
%create a sine wave corresponding to the change in frequency
tone=zeros(L,1);
for j=1:length(L)
tone(j)=sin(2*pi*f(j)*L(j)/SR+ pi);
end
toc

%envelope
gain=sin(pi*L/(t*SR));
%envelope to wave
click= tone .* gain;


%create noise
clicknoise=(rand(1,length(click))-0.5)/(1/NoiseLevel);
%add noise
for i=1:length(click);
   click(i)=click(i)+clicknoise(i);
end


%plot the click
plot(click)


%return the click for the function
click1= click;