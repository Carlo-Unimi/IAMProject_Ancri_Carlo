function Chroma=chroma_features(filename,windowLength,stepLength)
% example for the extraction of spectral_centroid, spread, rolloff and MFCCs
[y,fs]=audioread(filename);
if size(y,2)==2, y=sum(y,2)/2; end
Ham = window(@hamming, round(windowLength*fs)); % smooths the data in the window
[M,nf]=windowize(y, round(windowLength*fs), round(stepLength*fs)); 
% initialization of the feature vectors
Chroma=zeros(12,nf);
for i=1:nf
    frame = M(:,i);
    frame  = frame .* Ham;
    frameFFT = getDFT(frame, fs);
    Chroma(1:12,i) = feature_chroma_vector(frameFFT, fs);
end