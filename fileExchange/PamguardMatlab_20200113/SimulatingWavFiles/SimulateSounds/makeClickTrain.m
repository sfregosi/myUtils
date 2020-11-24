clear
% create a wav file of equally spaced popoise clicks 
noise=0.1;
sampleRate=500000;
channels=10;


click=MakePorpoiseClick(135000, 135000, 0.0001, noise, 500000);
clickNoise=(rand(1,250000)-0.5)*noise;


for j=1:channels
    
    clickNoise=(rand(1,250000)-0.5)*noise;
    wav=[];

for  i=1:20
   
   wav=[wav clickNoise click];
    
end

    wavAll(j,:)=wav;
    
end

wav=0.7*wav;

wavwrite(wavAll',sampleRate,16,'C:\Users\spn1\Desktop\clicksWav10CHan.wav');

