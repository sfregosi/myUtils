function [arriv] = arrival_at_microphones(time,bat,mikes,ch,fs,c)

distance = sqrt(sum((ones(length(mikes(:,1)),1)*bat-mikes).^2,2));
deltadist = distance - distance(ch);
deltatime = deltadist/(c);
deltafs = round(deltatime*fs);
arriv = time+deltafs;