clear 
% addpath(genpath('X:\Projects\Lab_Materials\Analysis_Tools_and_Software\fieldtrip-20200831'))
addpath(genpath('Y:\Analysis_Tools_and_Software\BIDS_pipeline-main\fieldtrip-master'))

% PtInfo=readtable(['F:\Dropbox (Personal)\ACPProjects\MechanismsUnderlyingStimulation\Data_Information_Spreadsheets\HPStimFileList_2.xlsx'],'Sheet','MasterList');
% Patients=table2cell(PtInfo(1:end,1));
% List=table2cell(PtInfo(1:end,3));


% PtInfo=readtable(['Y:\ReconComparisonTests\ComparisonReconProcesses.xlsx']);
% Patients=table2cell(PtInfo(1:end,1));
% List=table2cell(PtInfo(1:end,2));
Patients={'MG117','MG130','MG170','MG172','MG173','MG182','MG183',};
List={'sub-pt06','sub-pt09','sub-pt10','sub-pt11','sub-pt12','sub-pt13','sub-pt14'};

SaveDirectory='Z:\Volitional_Communication\DeidentifiedData\';

%%
clear ct mri mri_anon ct_anon
NUMCh=1;
Part=Patients{NUMCh};
sub_XXXX=List{NUMCh};
Part
sub_XXXX
%%
% ['X:\Original Data\',Part(1:2),'\',Part,'\',Part,'_Notes_and_Images\',Part,'_SurferOutput\mri\mri.nii']
mri = ft_read_mri(['X:\Original Data\',Part(1:2),'\',Part,'\',Part,'_Notes_and_Images\',Part,'_SurferOutput\mri\T1.nii']);
cfg = [];
mri_anon = ft_defacevolume(cfg, mri);
%
DirecSaveper=[SaveDirectory,sub_XXXX,'\ses-preimp\anat\'];
mkdir(DirecSaveper)
filename_MRI = [sub_XXXX,'_ses-preimp_acq-MRI_run-01_T1w.nii'];
ft_write_mri([DirecSaveper,filename_MRI], mri_anon.anatomy, 'transform', mri_anon.transform, 'dataformat', 'nifti');

%%
ct = ft_read_mri(['X:\Original Data\',Part(1:2),'\',Part,'\',Part,'_Notes_and_Images\',Part,'_SurferOutput\mri\ct.nii']);
%
cfg = [];
ct_anon = ft_defacevolume(cfg, ct);

filename_MRI = [sub_XXXX,'_ses-postimp_acq-CT_run-01_T1w.nii'];
ft_write_mri([DirecSaveper,filename_MRI], ct_anon.anatomy, 'transform', ct_anon.transform, 'dataformat', 'nifti');
NUMCh
%%
% 
% ct = ft_read_mri(['Y:\ReconComparisonTests\test2\IM-0001-0172-0001.nii']);
% %
% cfg = [];
% ct_anon = ft_defacevolume(cfg, ct);
% %
% ft_write_mri(['Y:\ReconComparisonTests\test2\test2.nii'], ct_anon.anatomy, 'transform', ct_anon.transform, 'dataformat', 'nifti');
% NUMCh
% [30 0 0]
% [200 150 125]
% [0 80 -85]
% cfg = [];
% ft_sourceplot(cfg, ct_anon);
%%
% cfg = [];
% cfg.output    = {'brain'};
% seg = ft_volumesegment(cfg, mri);
% 
% % copy the anatomy into the segmentation for plotting
% seg.anatomy = mri.anatomy;
% 
% cfg = [];
% cfg.funparameter = 'brain';
% ft_sourceplot(cfg, seg);
% 
% % add some padding to the brain by inflating it
% se = strel('sphere', 5);
% seg.brain = imdilate(seg.brain, se);
% 
% cfg = [];
% cfg.funparameter = 'brain';
% ft_sourceplot(cfg, seg);
% 
% % we do the MRI defacing here
% cfg = [];
% cfg.method = 'box';
% cfg.rotate = [-15 0 0];
% cfg.scale = [150 75 100];
% cfg.translate = [0 100 -30];
% defaced_mri = ft_defacevolume(cfg, mri);
% 
% % put the brain anatomy back using the padded brain segmentation
% defaced_mri.anatomy(seg.brain) = mri.anatomy(seg.brain);
% 
% cfg = [];
% ft_sourceplot(cfg, defaced_mri);
