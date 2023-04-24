
Data
- Corresponding .ns3 and .nev files

Code
- This code calls on functions from 
- Rina’s CLoSES-DataAnalysis repository
- bids-matlab: github.com/bids-standard/bids-matlab
- fieldtrip: github.com/fieldtrip/fieldtrip
- JSONio: github.com/gllmflndn/JSONio


SCRIPT: BIDS_data_clipping_front.m
-	Type in the variables:

o	pName: the patient’s name (e.g. MG169)

o	resultsPath: this is where the new trimmed nsx files will be saved

o	file_being_split: the name of the nsp1 ns3 file (will be used for organizational purposes)

o	fileNameNSxPerNSP: the NSP1 and NSP2 ns3 files

o	fileNameNEVPerNSP: the NSP1 and NSP2 nev files 

o	selChName1: the channels that will serve as a visual reference when selecting where to clip the nsx files

o	buffer_time_minutes: the number of minutes that will be added before and after each session (e.g. if buffer_time_minutes = 2, then a stim network session that lasts 5 minutes will have a clip duration of 2+5+2 = 9 minutes)

•	run the function

•	a plot with the input channels will pop up and the user can click at the start and end of each session and press enter

![image](https://user-images.githubusercontent.com/76748014/226079427-48bb8944-df76-40db-b94b-047649373b95.png)

 

•	a new window will pop up with subplots of all your selected sessions

•	the command window will prompt you for the name of the first session, type the name in the command window and press enter (this will be the name of the new nsx files, “Session1.ns3”, “Session1.nev”)

![image](https://user-images.githubusercontent.com/76748014/226079434-f5fd6ebb-9e46-4e63-b7ae-3d07c995d265.png)

 

•	The command window will then ask to confirm whether you want to save the file, type “Y” and press enter to continue

•	This will repeat for each session

•	When finished, you can find your newly clipped ns3 and nev files in the results path you specified



SCRIPT: createBIDS_front.m

Maindir:  This is here the FT_Analyzed data is located
-	If your data is in ‘W:\StimDataBackup\Data_Stimulation\MGxxx\NetworkWake1\FT_Analyzed\UpdatedFT_Analyzed, then Maindir = 'W:\StimDataBackup\Data_Stimulation\'

Bidsfolder: This is where your BIDS data will be saved

patient_id_map: An excel sheet holding ‘participant’ ID, ‘paper’ , and anonymous ‘IdentifierAcrossTheDataSet’ for a single patient. It should have the structure:

<img width="468" alt="image" src="https://user-images.githubusercontent.com/76748014/233897775-94127ff1-258f-403a-9d30-9aacae533927.png">

create_edf: Indicate whether to export edf files. By default, this script will export brainvision files. If create_edf = 0, it will not export edf files. If create_edf = 1, it will export edf files in addition to the brainvision files.

notes_on_instructions: Edit these notes to include descriptions of the session, such as whether the patient was awake or asleep. This will be added to the _ieeg.json files.

post_imp_scan: Indicate what kind of post implantation scan was done. The default is MRI.

sEEG_channels, scalp_channels, triggers_channels: sEEG, scalp, and trigger channels in the header structure for the exported brainvision/edf files

