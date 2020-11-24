% arrayElements=[[0,0,-3.21668];[0,0,-3];[0,0,-17.592];[0,0,-17.3491];[0,0,-12.0727];[0,0,-7.42231]];
% arrayElements=[[0,0,-3.21122];[0,0,-3];[0,0,-24.2689];[0,0,-24.1362];[0,0,-9.86172];[0,0,-16.8413]];
% arrayElements=[[0,0,-3.2423];[0,0,-3];[0,0,-24.54356];[0,0,-24.3187];[0,0,-9.936984];[0,0,-16.94719]];

%  arrayElements=[[2.9,3.3,-25.7];[2.9,3.3,-21.638];[2.9,3.3,-9.608];[2.9,3.3,-3.442];[2.9,3.3,-13.604];[2.9,3.3,-17.652];[0.086, -0.064, 1.067];[-0.152 -0.064 1.067];[-0.022 0.086 1.002];[-0.022 -0.182 1.002]];

speedOfSound=1500;
samplerate=500000;
noise=0.1;
padding=0.04; %seconds

soundWav=makeClick(140000,140000,0.0002,noise,samplerate);


wavArray=[];
for i=1:200

sourceLoc=[i,0,-35];

wavArray=[wavArray simulateSourceWav( arrayElements, sourceLoc, soundWav,speedOfSound, noise, samplerate) noise*rand(length(arrayElements),samplerate*padding)];

end

wavwrite(0.5*wavArray',samplerate,16,'C:\Users\spn1\Desktop\20110514 SimWav z-35.wav');
