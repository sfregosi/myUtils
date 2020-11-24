clear
%this creates a wav file which contains clicks seperated by correct time
%delays for a source at locations specified by sAll.

%sound speed
c=1500;

%source position
% s=[80 30 30];
sAll=[60 60 60; 40 40 40;  120 80 30 ];

%hydrophone positions
% % xPos=[5 0 10 30 0 8];
% % yPos=[5 0 5 0 20 12];
% % zPos=[5 10 15 20 25 30];
xPos=[0 0  0 0 10.392 20.784 31.176 10.392 20.784 2 2 33.176];
yPos=[0 12 24 36 6 12 18 30 24 0 36 18];
zPos=[22 30 30 22 30 30 22 30 30 22 22 22];

Noise=0.1;
sampleRate=500000;
totallength=5;

%create the click to use
click=MakePorpoiseClick(50000, 150000, 0.0001, 0.2, 500000);

%calculate travel times to each hydrophone for every source pos;
travelTimesAll=[];
for j=1:length(sAll)
s=sAll(j);    
travelTimesAll= [travelTimesAll; CalcAcousticTravelTimes(xPos, yPos, zPos, s, c)];
end

%create a channel for each travel time


for j=1:length(sAll)
    
    s=sAll(j,:);
    travelTimes=travelTimesAll(j,:);
    
    soundWav=zeros(length(travelTimes),round(totallength*sampleRate)+2*length(click)+1000);

    for i=1:length(travelTimes)
    
      %create random noise before click
      clicknoise=(rand(1,round(travelTimes(i)*sampleRate))-0.5)*Noise;
      %create random noise after click
      finishNoise=(rand(1,totallength*sampleRate-round(travelTimes(i)*sampleRate))-0.5)*Noise;
      
      %create click and noise plus insert a random echo every so often
      if round(length(travelTimes)*rand())==i
      sound=[clicknoise click (rand(1,1000)-0.5)*Noise click  finishNoise];
      else
      sound=[clicknoise click (rand(1,(1000+length(click)))-0.5)*Noise   finishNoise];
      end

      %soundWav(i,:)=sound;
      %add sound to wav file array
      soundWavAll(i,(j-1)*length(sound)+1:j*length(sound))=sound;
      
    end
    
end


%create the wav file
wavwrite(soundWavAll',sampleRate,16,'C:\Users\spn1\Desktop\TELSim.wav')