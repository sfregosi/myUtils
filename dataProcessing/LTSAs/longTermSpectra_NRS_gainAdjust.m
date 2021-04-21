%% Get NRS system response (SR) from xls pre-amp gain tables
% SR is the system response including hydrophone sensitivity and pre-amp response


%read xls preamp info 
%[f,g,HS] = importNRScal(workbookFile,sheetName);

%[f,g,HS] = importNRScal('C:\Users\haver\Documents\NRS\NRS10\NRS10_PreampCal.xlsx','1st Dep');
%[f,g,HS] = importNRScal_02('C:\Users\haver\Documents\NRS\NRS02\NRS02_PreampCal.xlsx','Dep1');
[f,g,HS] = importNRScal_2('C:\Users\haver\Documents\NRS\NRS04\NRS04_PreampCal.xlsx','Dep1');

%% interpolate values for all Hz
[SR] = calc_sys_response_NRS(f,g,HS);

%% Apply to gram

%create matrix of dB adjustment values
dB_gram = repmat(SR, 1, size(gram,2));

%% add to gram values and take absolute val
gainAdj_gram = gram - dB_gram;

%% Check gain!
%gainAdj_gram = gainAdj_gram - 12;

%% Save LTSA
cd C:\Users\haver\Documents\NRS\NRS04\LTSA

save NRS04_20152016_1hrAvgSpect_adjusted gainAdj_gram dt0 dt1 frameSize sRate
