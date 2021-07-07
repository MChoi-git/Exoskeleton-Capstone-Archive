function [rawText,dimensionNames,dimMagnitudeIndex,dimMagnitudeLength,dimMagnitude,export] = TextOut(component,componentName)
%Text Out
%Written by: Matthew Choi
%Last updated: Nov. 30, 2019
%Input: Finalized component object and force, sf, and fatigue structures
%Output: Component dimension text file
%Description: Takes a component and the structures, and exports the proper
%text file containing global variable for solidworks to read.
%Notes: Technically complete, not tested

%% Check if component file exists %%
%If it exists then continue, if not throw error
if isfile(componentName) %If file does not exist
    disp("File could not be found.");
end

%% Scan file for text%%
%Save the names of dimensions and their values
%componentName(isspace(componentName)) = []; %Removing all spaces from file name
%componentName = strcat(componentName,'1'); %Putting component names in structure identification format
%addpath(genpath('Text files'));
filePath = what('C:\MCG 4322B\Group 11\Solidworks\Equations');%what('Text files');
filePath = filePath.path;

fileID = fopen(strcat(filePath,'\',sprintf('%s.txt',componentName)),'r+'); %Open the file
formatSpec = '%c';
rawText = fscanf(fileID, formatSpec);

fclose(fileID);

%% Parse Dimension Names %%
%Sort through file and determine the names of dimensions, save index of
%dimension magnitudes
dimensionNames = strings(20);
dimMagnitudeIndex = zeros(20);
dimMagnitudeLength = zeros(20);
dimMagnitude = strings(20);
dimNamesIndex = 1;
dimMagIndex = 1;
nameFlag = false;

%Iterate across the string and extract dimension names (de-limited by
%quotation marks)
rawText = regexprep(rawText,'[\n\r]+','~');
i = 1;
while(i < length(rawText)) 
    if (rawText(i) == '"' && nameFlag == false) %First quotation mark hit
        nameFlag = true; %Now within quotation marks
    elseif (nameFlag ~= true && rawText(i) == '=' && rawText(i+1) == ' ' && rawText(i+2) ~= '"') %If a magnitude is encountered
        dimMagnitudeIndex(dimMagIndex) = i + 2;
        i = i + 2;
        while(i < length(rawText) && isstrprop(rawText(i),'digit') || rawText(i) == '.')
            dimMagnitudeLength(dimMagIndex) = dimMagnitudeLength(dimMagIndex) + 1;
            dimMagnitude(dimMagIndex) = strcat(dimMagnitude(dimMagIndex),rawText(i));
            i = i + 1;
        end
        dimMagIndex = dimMagIndex + 1;
    elseif (nameFlag == true) %Extract name with a loop
        if(i > 3 && rawText(i-3) == '=') %If the dimension name is used on the right side of an equation, skip it
            while(rawText(i) ~= '"' && i < length(rawText))
                i = i + 1;
            end
            dimNamesIndex = dimNamesIndex - 1;
        end
        while(rawText(i) ~= '"' && i < length(rawText)) %Loop until next quotation mark
            dimensionNames(dimNamesIndex) = strcat(dimensionNames(dimNamesIndex),rawText(i)); %Concatenate character, build name 
            i = i + 1;
        end
        dimNamesIndex = dimNamesIndex + 1; %Move to next index in dimensionNames array
        nameFlag = false; %Reset nameFlag
    end
    i = i + 1;
end

%% Pull In Dimension Values From Component Object %%
%Grab dimension values from component object to be written into the text
%file
% for i = 1:length(dimensionNames) %DimensionNames should be changed to match the dimension names of the obj, not the txt file
%     dimensionExports(i) = component.(dimensionNames(i)); %Save the new dimensions to be written to txt file
% end

%% Remove Non-Necessary Dimensions %%
i = 1;
while i <= length(dimensionNames)
    if (contains(dimensionNames(i),'@'))
        dimensionNames(i) = [];
    else
        i = i + 1;
    end
end

dimensionNames(cellfun('isempty',dimensionNames)) = [];
dimMagnitude(cellfun('isempty',dimMagnitude)) = [];
dimMagnitudeIndex = dimMagnitudeIndex(dimMagnitudeIndex~=0)';
dimMagnitudeLength = dimMagnitudeLength(dimMagnitudeLength~=0)';
% for i = 1:length(dimensionNames) TESTER
%     disp(dimensionNames(i));
% end



%% Update dimensions in text file %%
% Overwrite the dimension magnitudes using the component object
% Note: Ask Jen to rename her variables to the actual variable names in the
% code
%addpath(genpath('Test output'));
filePath = what('C:\MCG 4322B\Group 11\Solidworks\Equations'); %what('Test output');
filePath = filePath.path;
fileID = fopen(strcat(filePath,'\',sprintf('%s.txt',componentName)),'w'); %Open the file
formatSpec = '%s';

export = strtrim(regexprep(rawText,'[\n\r]+','~'));
for i = 1:length(dimensionNames) %Loop through all dimensions
    if (i == length(dimensionNames)) %If value is at the end of the file, just splice once
        if (i == 1) %If there is only one dimension
            splice1 = export(1:dimMagnitudeIndex(i) - 1); %Save text up until before first char to be removed (dimension value)
            splice2 = export((dimMagnitudeIndex(i) + dimMagnitudeLength(i)):length(export));
            export = join([splice1,sprintf('%.4f',component.(dimensionNames{i})),splice2]);
        elseif (i ~= 1 && i == length(dimensionNames)) %End of dimensions, but non-necessary dimensions still follow
            splice1 = export(1:dimMagnitudeIndex(i) - 1); %Save text up until before first char to be removed (dimension value)
            splice2 = export((dimMagnitudeIndex(i) + dimMagnitudeLength(i)):length(export));
            export = join([splice1,sprintf('%.4f',component.(dimensionNames{i})),splice2]);
        else %Dimension at the end of the file, nothing after
            splice = export(1:dimMagnitudeIndex(i) - 1);
            sprintf('%.4f',component.(dimensionNames{i}));
            export = join([splice,sprintf('%.4f',component.(dimensionNames{i}))]);
        end

        %disp('loop1');
    else
        splice1 = export(1:dimMagnitudeIndex(i) - 1); %Save text up until before first char to be removed (dimension value)
        splice2 = export((dimMagnitudeIndex(i) + dimMagnitudeLength(i)):length(export)); %Save text after termination of the dimension value
        dimMagnitudeLengthNew(i) = length(sprintf('%.4f',component.(dimensionNames{i})));
        for j = i + 1:length(dimensionNames)
            dimMagnitudeIndex(j) = dimMagnitudeIndex(j) + (dimMagnitudeLengthNew(i) - dimMagnitudeLength(i));
        end
        
        export = join([splice1,sprintf('%.4f',component.(dimensionNames{i})),splice2]); %Concatenate the new dimension between the splices (replace)
        %disp('loop2');
    end
%     fprintf(fileID,formatSpec,export); %Print the final export string into the text file
%     "width1" = 0.4m            INITIAL VALUES
%     "CORabd" = 0.1671m
%     "hipMember_T" = 0.02m
end
export = strtrim(regexprep(export,'~','\n\r'));
fprintf(fileID,formatSpec,export); 
fclose(fileID);

%% Unused %%
% %% Parse Dimension Magnitudes %% CURRENTLY NOT NEEDED
% %Sort through file and determine magnitudes of dimensions and assign them
% dimensionMagnitudes = zeros(20);
% index = 1;
% %Iterate across the string and extract dimension magnitudes (identified by
% %'= ' prefix)
% i = 1;
% while(i ~= length(rawText))
%     if(rawText(i) == '=' && rawText(i+1) == ' ') %Magnitude identifier reached
%         i = i + 2; %Move index to first digit of number
%         while(isstrprop(rawText(i),'digit') || rawText(i) == '.') %Iterate through number including decimals
%             dimensionMagnitudes(index) = str2double(strcat(dimensionNames(index),rawText(i)));
%             i = i + 1;
%         end
%         index = index + 1; %Move dimensionMagnitudes pointer up one
%     end
%     i = i + 1;
% end

end

