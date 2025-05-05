function features = extract_from_path(path,extension,windowLength,stepLength)
addpath(genpath(path))
files = dir([path,'*.',extension]);
features=[];
for i=1:length(files)
    ceps=extractMFCCs(files(i).name,windowLength,stepLength);
	features = [features ceps];
end