
function [click1]=makeClick(Startf, Endf, t, NoiseLevel, SR)
%Startf- start frequency. (Hz)
%Endf- end frequency. (Hz)
%t- click length (s)
%NoiseLevel- noise to add to click. generally 0->1
%SR- samplerate
% e.g.  makeClick(140000, 140000, 0.0001, 0.2, 500000) -porpoise click

t1= 1/50; %Spacing between click= length of silent/noise period before and after each click

% Startf= 135000;  %Start Click Frequency
% Endf=135000; %End Click Frequency

% SR= 500000; %Sample Rate


%Make Click
L=0:(t * SR);

%instananeous frequency
f=zeros(L,1);
f(1)=Startf;
tic
for i=2:length(L)
    Increment=(Endf-Startf)/length(L);
    f(i)=f(i-1)+Increment;
end
toc
tic
tone=zeros(L,1);
for j=1:length(L)
tone(j)=sin(2*pi*f(j)*L(j)/SR+ pi);
end
toc




gain=sin(pi*L/(t*SR));

click= tone .* gain;


t2= t1 - t;

L=0:(t2 * SR);


silence=L*0;
noise=(rand(1,length(L))-0.5)/(1/NoiseLevel);
clicknoise=(rand(1,length(click))-0.5)/(1/NoiseLevel);
for i=1:length(click);
    
   click(i)=click(i)+clicknoise(i);
   
end

plot(click)

click1= click;