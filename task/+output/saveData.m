function saveData(options, dataFile)

mkdir(fullfile(options.files.savePath));

save(fullfile([options.files.savePath,'/',options.files.dataFileName]),'dataFile');

diary off
save(fullfile([options.files.savePath,'/diary']));

end
