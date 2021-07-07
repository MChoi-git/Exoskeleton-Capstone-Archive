function [logSFNames,logSFValues,export] = LogOut(sfStruct,fatigueStruct)
%Log Out
%Written by: Matthew Choi
%Last updated: Nov. 30, 2019
%Input: Minimum safety factor and fatigue safety factor structures
%Output: Log file containing minimum safety factors and fatigue safety
%factors
%Description: Takes minimum safety and fatigue safety factors and prints
%them out as-is into a log file

%% Safety Factor and Component Names %%
sfNames = {'n_stress_shelf','n_stress_Bracket1_R','n_GasSpringBolt1_R','n_bottomBracket_R','n_stress','n_capacity_BearingAA_R'...
    ,'n_shear_hipStopper_R','n_stress_hipStopper_R','n_stress_ShaftAA_R','n_stress_keys_R','n_stress_HipMember2_R','n_stress_PlungerEF_R'...
    ,'n_stress_PlungerScrew_R','n_capacity_hipBearingEF_R','n_shear_hipSpring_R','n_stress_BearingCasingScrew_R','n_attachment_R'...
    ,'n_stress_thigh_R','n_foamTH_R','n_failure_kneeBushing_R','n_shear_kneePin_R','n_bending_ratchet_R','n_shear_Fspring_R'...
    ,'n_yield_Pawl_R','n_shear_pawlPin_R','n_supture_PawlString_R','nmin_shank_R','n_stress_ubar_R','n_bolt_Abolt_R'...
    ,'n_DE_Cboot_R','n_thighScrew','n_shankScrew'};

fatigueSFNames = {'n_fatigue_shelf','n_fatigue_ShaftAA_R','n_MG_hipMember2_R','n_fatigue_PlungerEF_R','n_fatigue_hipSpring_R'...
    ,'n_fatigue_thigh_R','n_fatigue_ratchet_R','n_fatigue_PawlSpring_R','n_fatigue_Pawl_R','n_fatigue_n_fatigue_Shank_R'...
    ,'n_fatigue_n_fatigue_Shank_R','n_MG_cboot_R','n_fatigue_hipStopper_R'};

components = {'aBolt1' 'attachmentPlate1' 'bearingAA1' 'bearingCasingEF1' 'bottomBracket_L1' 'bottomBracket_R1' 'exoThigh1' 'uBar1'...
                                                    'exoShank1' 'foamThigh1' 'gasSpring1' 'gasSpringBolts1' 'hipFlexExBearing1'...
                                                    'hipMember1' 'hipMember21' 'hipString1' 'hipStopper1' 'hipStopperPin1' 'keys1'...
                                                    'kneePin1' 'pawl1' 'foamShank1' 'pawlPin1' 'pawlString1' 'plungerCasingEF1' 'plungerEF1'...
                                                    'plungerScrewEF1' 'ratchet1' 'shaftAA1' 'shelf1' 'thighScrew1' 'shankScrew1' 'topBracket_L1'...
                                                    'topBracket_R1' 'cBoot1'};

%% Creating Safety Factor Matrices %%
%Initialize name and value arrays
logSFNames = strings(length(sfNames) + length(fatigueSFNames),1);
logSFValues = zeros(length(sfNames) + length(fatigueSFNames),1);

index = 1;

for i = 1:length(components)
    for j = 1:length(sfNames)
        if isfield(sfStruct.(components{i}),sfNames(j)) %If the component i and sf j exist, save the name and value
            logSFNames(index) = sfNames{j};
            logSFValues(index) = min(sfStruct.(components{i}).(sfNames{j}));
            index = index + 1;
        end
    end
end
for i = 1:length(components)
    for j = 1:length(fatigueSFNames)
        if isfield(fatigueStruct,components{i}) && isfield(fatigueStruct.(components{i}),fatigueSFNames(j)) %If the component i and sf j exist, save the name and value
            logSFNames(index) = fatigueSFNames{j};
            logSFValues(index) = min(fatigueStruct.(components{i}).(fatigueSFNames{j}));
            index = index + 1;
        end
    end
end

%% Formatting Safety Factor Matrices %%
logSFValues = cellstr(num2str(logSFValues));
export = strings(50,1);
for i = 1:length(logSFNames)
    export(i) = strcat(logSFNames(i),' = ',logSFValues(i));
end

export = export(1:40);

%% Open File %%
%addpath(genpath('Log file'));
filePath = what('C:\MCG 4322B\Group 11\Log');
filePath = filePath.path;
fileID = fopen(strcat(filePath,'\','LOG.txt'),'w'); %Open open the log file

fprintf(fileID,'%s\n',export);

fclose(fileID);




end

