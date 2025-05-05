function features = extract_from_path_chroma(path,extension,windowLength,stepLength)
addpath(genpath(path))
files = dir([path,'*.',extension]);
features=[];
for i=1:length(files)
    chroma=chroma_features(files(i).name,windowLength,stepLength);
	features = [features chroma];
end