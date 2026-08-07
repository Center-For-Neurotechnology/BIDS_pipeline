function blackrock_ns3_to_edf(filenameNSx, outputEdfFilename)
% BLACKROCK_NS3_TO_EDF  Convert a Blackrock .ns3 file to EDF format
%   using MATLAB's native edfwrite, preserving correct physical and
%   digital calibration values from the Blackrock hardware.
%
% USAGE:
%   blackrock_ns3_to_edf('path/to/file.ns3', 'path/to/output.edf')
%
% INPUTS:
%   filenameNSx       - full path to the .ns3 file
%   outputEdfFilename - full path for the output .edf file
%
% REQUIRES:
%   - NPMK toolbox (for openNSx)
%   - MATLAB Signal Processing Toolbox (for edfwrite, edfheader)

%% 1. Read the .ns3 file using NPMK
fprintf('Reading: %s\n', filenameNSx);
dataNSx = openNSx(filenameNSx, 'read', 'report');

%% 2. Extract raw data
% If cell (paused recording), keep the last segment
if iscell(dataNSx.Data)
    rawData = dataNSx.Data{end};
    fprintf('Warning: Data has multiple segments. Using the last segment.\n');
else
    rawData = dataNSx.Data;
end
% rawData is int16: [nChans x nSamples]

[nChans, nSamples] = size(rawData);
fprintf('Channels: %d, Samples: %d\n', nChans, nSamples);

%% 3. Get sampling frequency
Fs = dataNSx.MetaTags.SamplingFreq;
fprintf('Sampling frequency: %d Hz\n', Fs);

%% 4. Extract per-channel calibration and labels
channelLabels = strings(nChans, 1);
physMax = zeros(nChans, 1);
physMin = zeros(nChans, 1);
digMax  = zeros(nChans, 1);
digMin  = zeros(nChans, 1);
physDim = strings(nChans, 1);

for ch = 1:nChans
    % Channel label
    channelLabels(ch) = deblank(string(dataNSx.ElectrodesInfo(ch).Label));
    
    % Hardware calibration range
    physMax(ch) = double(dataNSx.ElectrodesInfo(ch).MaxAnalogValue);   % e.g.  8191
    physMin(ch) = double(dataNSx.ElectrodesInfo(ch).MinAnalogValue);   % e.g. -8191
    digMax(ch)  = double(dataNSx.ElectrodesInfo(ch).MaxDigiValue);     % e.g.  32764
    digMin(ch)  = double(dataNSx.ElectrodesInfo(ch).MinDigiValue);     % e.g. -32764
    
    % Physical units
    physDim(ch) = deblank(string(dataNSx.ElectrodesInfo(ch).AnalogUnits)); % e.g. 'uV'
end

%% 5. Apply Blackrock scaling (digital -> physical values)
% Scale factor: converts raw int16 to physical units (e.g., uV)
% Blackrock Central 7+ packets may be off by a factor of 4
scaledData = zeros(nChans, nSamples);
for ch = 1:nChans
    gain = (physMax(ch) - physMin(ch)) / (digMax(ch) - digMin(ch));
    scaledData(ch, :) = gain * double(rawData(ch, :));
end

%% 6. Build EDF header using MATLAB's edfheader
hdr = edfheader("EDF");
hdr.NumSignals      = nChans;
hdr.SignalLabels     = channelLabels;
hdr.PhysicalDimensions = physDim;
hdr.PhysicalMin      = physMin;
hdr.PhysicalMax      = physMax;
hdr.DigitalMin       = digMin;
hdr.DigitalMax       = digMax;

% Data record configuration
% Use 1-second records (standard for EDF)
hdr.DataRecordDuration = seconds(1);
hdr.NumDataRecords     = ceil(nSamples / Fs);

% Trim data to fit exact number of complete records
nSamplesUsed = hdr.NumDataRecords * Fs;
if nSamplesUsed > nSamples
    fprintf('Padding %d samples to fill the last record.\n', nSamplesUsed - nSamples);
    scaledData(:, end+1:nSamplesUsed) = 0;
end

%% 7. Format data for edfwrite
% edfwrite expects data as [nSamples x nChans] (column-per-channel)
dataForEdf = scaledData';  % transpose to [nSamples x nChans]

%% 8. Write the EDF file
fprintf('Writing EDF: %s\n', outputEdfFilename);
edfwrite(outputEdfFilename, hdr, dataForEdf, 'InputSampleType', 'physical');

%% 9. Verify
info = edfinfo(outputEdfFilename);
fprintf('\n--- EDF Verification ---\n');
fprintf('Signals:     %d\n', info.NumSignals);
fprintf('Records:     %d\n', info.NumDataRecords);
fprintf('PhysicalMin: ');  disp(info.PhysicalMin');
fprintf('PhysicalMax: ');  disp(info.PhysicalMax');
fprintf('DigitalMin:  ');  disp(info.DigitalMin');
fprintf('DigitalMax:  ');  disp(info.DigitalMax');
fprintf('Units:       ');  disp(info.PhysicalDimensions');
fprintf('Done.\n');

end