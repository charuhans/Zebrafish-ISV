function dosages = getDosage(textDosage)

dosages=cell(10000,1);
sizeDosages = 10000;
lineCt = 1;
fid = fopen(textDosage);
tline = fgetl(fid);
while ischar(tline)
   dosages{lineCt} = tline;
   lineCt = lineCt + 1;
   %# grow s if necessary
   if lineCt > sizeDosages
       dosages = [dosages;cell(10000,1)];
       sizeDosages = sizeDosages + 10000;
   end
   tline = fgetl(fid);
end
%# remove empty entries in s
dosages(lineCt:end) = [];