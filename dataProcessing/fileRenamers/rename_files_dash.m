%Convert file names for LTSA in Triton

files = dir('*.wav');

for i=1:length(files)
  [pathname,filename,extension] = fileparts(files(i).name);
  % the new name
  newFilenameA = filename(1:7);
  newFilenameB = filename(6:18);
  % rename the file
  movefile([filename extension], [newFilenameA,'-', newFilenameB,extension]);
  end
