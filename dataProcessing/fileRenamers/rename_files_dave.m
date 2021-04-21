%RENAMES GLIDER WISPR FILES FOR CREATING LTSA
% LTSA REQUIRES FILE FORMAT: YYMMDD-HHMMSS.wav

files = dir('*.wav');
for i = 1:length(files)
  nm = files(i).name;
  nm(nm == '_') = '-';
  if (~strcmp(files(i).name, nm)), movefile(files(i).name, nm); end
end 