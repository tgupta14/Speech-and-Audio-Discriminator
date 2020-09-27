clear;
close all;

overlap=0.5;

% Reading the speech audio files
speechFiles= dir('Speech Files');
cd ('Speech Files')

speechFeatures=[];

for i=3:size(speechFiles,1)
    [file, fs] = audioread(speechFiles(i).name);
    features= getAllFeatures(file, fs, overlap);
    speechFeatures= [speechFeatures;features];
end

% There is a possibility that spectral centroid will be NaN for frames that
% have zero amplitude for all samples. We need to delete these values
k = find(isnan(speechFeatures(:,3)));
speechFeatures(k,:) = [];

cd ..
% Reading the music audio files
musicFiles= dir('Music Files');
cd ('Music Files')

musicFeatures=[];

for i=3:size(musicFiles,1)
    [file, fs] = audioread(musicFiles(i).name);
    features= getAllFeatures(file, fs, overlap);
    musicFeatures= [musicFeatures;features];
end

k = find(isnan(musicFeatures(:,3)));
musicFeatures(k,:) = [];
cd ..

%We can find the BC Distance now to see how separable the two classes are
all_features_bc_distance= BCdistance(speechFeatures,musicFeatures);
fprintf(1, '\nThe BC Distance using complete set of features is: %1.3f \n', all_features_bc_distance); 

low_energy_bc_distance=BCdistance(speechFeatures(:,1),musicFeatures(:,1));
fprintf(1, '\nThe BC Distance using Low Energy Frames feature is: %1.3f \n', low_energy_bc_distance); 

spec_rolloff_bc_distance=BCdistance(speechFeatures(:,2),musicFeatures(:,2));
fprintf(1, '\nThe BC Distance using Spectral Rolloff Point feature is: %1.3f \n', spec_rolloff_bc_distance); 

spec_centroid_bc_distance=BCdistance(speechFeatures(:,3),musicFeatures(:,3));
fprintf(1, '\nThe BC Distance using Spectral Centroid feature is: %1.3f \n', spec_centroid_bc_distance); 

spec_flux_bc_distance=BCdistance(speechFeatures(:,4),musicFeatures(:,4));
fprintf(1, '\nThe BC Distance using Spectral Flux feature is: %1.3f \n', spec_flux_bc_distance); 

zcr_bc_distance=BCdistance(speechFeatures(:,5),musicFeatures(:,5));
fprintf(1, '\nThe BC Distance using Zero Crossing Rate feature is: %1.3f \n\n', zcr_bc_distance); 

% This is the function to obtain all 5 features for a frame
function allFeatures= getAllFeatures(signal, Fs, overlap)
    allFeatures=[];
    for a=1:2*length(signal)/Fs-2
        frame= signal((a-1)*overlap*Fs+1: ((a-1)*overlap+1)*Fs);
        frameNext= signal((a)*overlap*Fs+1: ((a)*overlap+1)*Fs);
        low_energy_frames= get_low_energy_frames(frame, Fs); %Low Energy Frame
        spectralRollOff= getSpectralRolloff(frame, Fs); %Spectral Rolloff Point
        spectralCentroid= getSpectralCentroid(frame); %Spectral Centroid
        spectralFlux=getSpectralFlux(frame,frameNext); %Spectral Flux
        ZCR=getZCR(frame); %Zero Crossing Rate
        allFeatures=[allFeatures; low_energy_frames, spectralRollOff, spectralCentroid, spectralFlux, ZCR];
    end
end

function low_energy_frames= get_low_energy_frames(frame, fs)
    count=0;
    N=fs/100;
    frame_rms_power= frame*frame'/fs;
    for i=1:100
        frame_10ms= frame((i-1)*N+1: i*N);
        frame_10ms_rms_power= frame_10ms*frame_10ms'/N;
        if frame_10ms_rms_power<frame_rms_power
            count=count+1;
        end
    end
    low_energy_frames=count;
end

function ZCR= getZCR(frame)
    ZCR= sum(frame(1:end-1).*frame(2:end)<0)/length(frame);
end

function spectralCentroid= getSpectralCentroid(frame)
    spectrum = abs(fft(frame));
    normalized_spectrum = spectrum(1, 1:length(spectrum)/2) / sum(spectrum(1, 1:length(spectrum)/2));
    normalized_frequencies = linspace(0, 1, length(spectrum(1, 1:length(spectrum)/2)));
    spectralCentroid = sum(normalized_frequencies.*normalized_spectrum);
end

function spectralFlux= getSpectralFlux(frame, next_frame)
    spectralFlux= norm((frame-next_frame),2);
end

function spectralRollOff= getSpectralRolloff(frame, Fs)
    spectrum = abs(fft(frame));
    afSum   = sum(spectrum(1, 1:length(spectrum)/2));
    cumulative_sum=cumsum(spectrum(1, 1:length(spectrum)/2));
    vsr  = find(cumulative_sum >= 0.95*afSum)-1;
    spectralRollOff= vsr(1,1)/ (Fs-1) * Fs/2;
end
