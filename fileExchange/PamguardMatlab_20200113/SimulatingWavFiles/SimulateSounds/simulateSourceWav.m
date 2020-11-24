function [ wavArray ] = simulateSourceWav( arrayElements, sourceLoc, soundWav,speedOfSound, noise, samplerate);
%SIMULATESOURCEWAV Creates an array simulating the multichannel sound that
%would be recieved from a sdource ata specified location
%   arrayElements- cartesian position of the hydrophone elements[[x,y,z]...] were z is
%   height i.e. depth is -z not +z
%   sourceLoc. the cartesian location of the source [x,y,z].
%   soundWav. A clip of the sound to be used in the simulated multichannel
%   file. e.g. could be a porpoise click

%works out the time it would take to travle from the source location to
%each element. 

for i=1:length(arrayElements)
    
    times(i)=round(calcTravelTime(arrayElements(i,:), sourceLoc, speedOfSound)*samplerate);
    
end

maxTime=max(times);

%now create the .wav array
for j=1:length(times)
    
   wav=[noise*rand(1,times(j)) soundWav noise*rand(1,maxTime-times(j))]; 
   disp(['Channel ' num2str(j) ': Write ' num2str(length(wav)) ' units.']);
   wavArray(j,:)=wav;

end

end

