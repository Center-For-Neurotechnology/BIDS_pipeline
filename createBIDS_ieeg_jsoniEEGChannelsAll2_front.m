Tarzan1_drive = 'W'; % assumes access to tarzan1
Maindir=[Tarzan1_drive,':\StimDataBackup\Data_Stimulation\']; % where the FT_Analyzed data is
Bidsfolder='W:\StimDataBackup\Data_Stimulation\jackie_pipeline_testing'; % full path where the new bids files will be saved
HPStimFileList_2 = 'E:\BIDStesting\dependencies\HPStimFileList_2.xlsx'; % excel file with sheets (MasterList and Sheet1)
DI=76; % patient number 

createBIDS_ieeg_jsoniEEGChannelsAll2_back(Tarzan1_drive,Maindir,Bidsfolder,HPStimFileList_2,DI)