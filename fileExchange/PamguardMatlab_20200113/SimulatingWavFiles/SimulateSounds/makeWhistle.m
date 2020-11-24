%Make a whistle
function [click1]=makeWhistle(Startf, Endf, t, NoiseLevel, SR)


% NoiseLevel=0.0; %Generally 0->1

% t= 0.0001; %Click Length


% Startf= 135000;  %Start Click Frequency
% Endf=135000; %End Click Frequency

% SR= 500000; %Sample Rate


%Make Click
L=0:(t * SR);

%instananeous frequency
f=zeros(1,L);
f(1)=Startf;
tic


Increment=(Endf-Startf)/length(L);
for i=2:length(L)
    i
   freq=f(i-1)+Increment;
    f(i)=freq;
   
end


 figure(1)
plot(f)


toc
tic
tone=zeros(1,L);

for j=1:length(L)
tone(j)=sin(2*pi*f(j)*L(j)/SR+ pi);
end
toc


click= tone;


clicknoise=(rand(1,length(click))-0.5)/(1/NoiseLevel);
for i=1:length(click);
    
   click(i)=click(i)+clicknoise(i);
   
end

plot(click)

click1= click;