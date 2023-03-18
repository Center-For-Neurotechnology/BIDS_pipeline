Data
•	Corresponding .ns3 and .nev files

Code
This code calls on functions from Rina’s CLoSES-DataAnalysis repository
1.	Start raw nsx file clipping
•	Open BIDS_data_clipping_front.m
•	Type in the variables:
o	pName: the patient’s name (e.g. MG169)
o	resultsPath: this is where the new trimmed nsx files will be saved
o	file_being_split: the name of the nsp1 ns3 file (will be used for organizational purposes)
o	fileNameNSxPerNSP: the NSP1 and NSP2 ns3 files
o	fileNameNEVPerNSP: the NSP1 and NSP2 nev files 
o	selChName1: the channels that will serve as a visual reference when selecting where to clip the nsx files
o	buffer_time_minutes: the number of minutes that will be added before and after each session (e.g. if buffer_time_minutes = 2, then a stim network session that lasts 5 minutes will have a clip duration of 2+5+2 = 9 minutes)
•	run the function
•	a plot with the input channels will pop up and the user can click at the start and end of each session and press enter
 
•	a new window will pop up with subplots of all your selected sessions
•	the command window will prompt you for the name of the first session, type the name in the command window and press enter (this will be the name of the new nsx files, “Session1.ns3”, “Session1.nev”)
•	 
•	The command window will then ask to confirm whether you want to save the file, type “Y” and press enter to continue
•	This will repeat for each session
•	When finished, you can find your newly clipped ns3 and nev files in the results path you specified
