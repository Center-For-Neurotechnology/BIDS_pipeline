% functions that use regular expressions on channel names
perSessionChannelsTSV % the only fxn! :) x

% functions that read eeg file data
perSessionChannelsTSV % gets header info x
perSessionIEEG % gets recording data x(need to test)
perSessionEventsTSV % gets stim index x(need to test)


%{
other notes:
- don't open non-recording channels (files starting w CSC)
- CSC289 is SYNC data
- these 2 neuralynx fxns should be enough to write the neuralynx BIDS
    pipleline

timeline:
- working with: MG197 NetworkWake1 (NetworkWake1 folder is organized to
    only contain the single network :)
- now that I have my test data, let's look at Rina's code's input/output!
    - GetBipolarEEGFromNeuralynx
        in: 
            - dirNeuraLynxData: path with csc data
            - posFixNCS: recording number (similar to nsp numbers) = '' if
                there is a single recording session in the folder
            - selChNames = chNamesToRead: cell of channel names (used to open each channel
                nsc file)
            - selBipolar: [] -> code includes isempty(selBipolar) 
            - stimChNames: chan with stim info {'CSC289'}
            - startNSxSec: 0 for start of file
            - endNSxSec: [] code has isempty(endNSxSec)
            - minDistSTIMPulses: [] code has isempty(minDistSTIMPulses)
        out:        (that i need)
            - indTimeAllSTIM
            - dataReferentialPerCh
            - allChNames = selChNames
            - hdr: includes Fs
    - readCSCfiles
        in:             (others are already defined in calling fxn) 
            - usePlot: hardcoded to 0

- should create two seperate user scripts for blackrock and neuralynx: it's
    easier to organize and use; seperate perSessionChannelsTSVn and
    continue!
- note: send updated repo to pariya
%}







%{
CNN notes:
keepInd = test_label_split~=0;
%}