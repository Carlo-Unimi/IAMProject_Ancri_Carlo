function procAndMrgAudio(genreName)
    testAudioFolder = fullfile(pwd, 'data', genreName, 'test', filesep);
    audioFiles = dir([testAudioFolder, '*mp3']);
    [noise, fs_noise] = audioread(fullfile(pwd, 'data', 'babble.wav'));
    
    noisyTestDir = fullfile(pwd, 'data', 'noisyTestDir', genreName, filesep);
    if ~exist(noisyTestDir, 'dir')
        mkdir(noisyTestDir);
    end
    addpath(noisyTestDir);

    for k = 1:length(audioFiles)
        audioFile = fullfile(testAudioFolder, audioFiles(k).name);
        [audio, fs_audio] = audioread(audioFile);
        audio = stereoToMono(audio);
        assert(fs_audio == fs_noise);

        if length(noise) < length(audio)
            rep = ceil(length(audio)/length(noise));
            noise = repmat(noise, rep, 1);
        end

        noiseSegment = noise(1:length(audio));
        [merged, ~] = sigmerge(audio, noiseSegment, 5);
        outFile = fullfile(noisyTestDir, audioFiles(k).name);
        audiowrite(outFile, merged, fs_audio);
    end
end