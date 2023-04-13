                          
electrodes_tsv_name = fullfile(root_dir, project_label, ['sub-' ieeg_sub], ['ses-' ieeg_ses], 'ieeg', ...
    ['sub-' ieeg_sub,'_ses-' ieeg_ses,'_electrodes.tsv']);

%% make a participants table and save
ElectrodeInfo={};
svc=1;
RAS=[];
for sismn=1:size(ChannelInformation,1)
    if isempty(ChannelInformation{sismn,1})==0 &&  isempty(strmatch(ChannelInformation{sismn,12},'SEEG'))==0
        RAS(svc,:)=[ChannelInformation{sismn,2} ChannelInformation{sismn,3} ChannelInformation{sismn,4} ChannelInformation{sismn,7}];
        ElectrodeInfo(svc,:)=ChannelInformation(sismn,:);
        svc=1+svc;
    end
end
%% required columns
name = ElectrodeInfo(:,11); % Name of the electrode contact point
x = RAS(:,1); % X position. The positions of the center of each electrode in xyz space.
y = RAS(:,2); % Y position.
z = RAS(:,3); % Z position. If electrodes are in 2D space this should be a column of n/a values.
Size = RAS(:,4); % Surface area in mm^2 A=2πrh+2πr2

%% recommended columns
material = repmat({'platinum'},size(ElectrodeInfo,1),1); % Material of the electrodes
manufacturer = ElectrodeInfo(:,6); % electrode manufacturer
group = ElectrodeInfo(:,17); % the group that the electrode is a part of, should match a group specified in `_channels.tsv`
hemisphere = ElectrodeInfo(:,9); % the hemisphere in which the electrode is placed, "L" or "R"

%% optional columns
type = repmat({'n/a'},size(ElectrodeInfo,1),1); %type of the electrode, eg.:cup, ring, clip-on, wire, needle, ...
impedance = repmat({'n/a'},size(ElectrodeInfo,1),1); % Impedance of the electrode in kOhm.

%% write a tsv file and a csv file just for later use
size=Size; % J: why is this step needed?
t = table(name, x, y, z, size, material, manufacturer, group, hemisphere, type, impedance);
writetable(t, electrodes_tsv_name, 'FileType', 'text', 'Delimiter', '\t');
clear size Size; % J: needed?