function saveData(expInfo, dataFile, protocol)

mkdir(fullfile(['+output/',expInfo.PPID]));

save(fullfile(['+output/',expInfo.PPID,'/dataFile.mat']));

diary off
save(['+output/+expLog',diaryname]);

end
