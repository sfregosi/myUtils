function [ nC ] = getChannels( channelMap )
% function nC = countChannels(channelMap)
% count the numebr of set bits in the channel map
nC =[];
j = 1;
for i = 1:32
    if (bitand(channelMap, j))
        nC = [nC ,i-1];
    end
    j = j * 2;
end

if (isempty(nC))
    nC=[0];
end
end

