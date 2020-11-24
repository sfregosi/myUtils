function ccall = impcomp(call,fs,mic,bat,temp,hum,mike_vector)
if mod(length(call),2)
    error('length of call should be an even number');
else
bat_mike_vector = mic-bat;    
[theta,phi,dist] = cart2sph(bat_mike_vector(1),bat_mike_vector(2),bat_mike_vector(3));
b = bat - mic;
a = mike_vector;
ang = atan2(norm(cross(a,b)),dot(a,b));
angle = round(ang.*180/pi);
Alfa = atmatt(temp,hum).*(dist-0.1);    
if angle == 0
    compensat = Alfa;
else
mikedir = load('GRAS40BFdirectionality_100Hz_110000Hz_1_90_deg.mat');
angcomp = mikedir.GRAS40BFdirectionality_100Hz_110000Hz_1_90_deg(:,angle);    

compensat = (Alfa-angcomp);
end
freq = [0 0.1:0.1:110 fs/2000];

fTL = interp1(freq,[0;compensat;0],linspace(0,fs/2000,length(call)/2+1),'pchip');
fTL = fTL(:);

fTL = 10.^(fTL/20);
ars = amprespsig(fTL);
ccall=filter(ars,1,call).*(dist/0.1);
end