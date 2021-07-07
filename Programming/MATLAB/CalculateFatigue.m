function [fatigueStruct] = CalculateFatigue(aBolt,attachmentPlate,bearingAA,bearingCasingEF,bottomBracket_L,bottomBracket_R...
                                                    ,exoThigh,uBar,exoShank,foamThigh,gasSpring,gasSpringBolts...
                                                    ,hipFlexExBearing,hipMember,hipMember2,hipSpring,hipStopper,hipStopperPin...
                                                    ,keys,kneePin,pawl,foamShank,pawlPin,pawlString,pawlSpring,plungerCasingEF...
                                                    ,plungerEF,plungerScrewEF,ratchet,shaftAA,shelf,thighScrew,shankScrew,topBracket_L...
                                                    ,topBracket_R,cBoot... 
                                                    ,flxExtHip_AngAcceleration,shank_AccelerationX,shank_AccelerationY,shank_AngAcceleration...
                                                    ,foot_AccelerationX,foot_AccelerationY,A4Hip_Acceleration,greaterTrochanter_AccelerationX...
                                                    ,greaterTrochanter_AccelerationY,com_Acceleration,abdAddHip_AngAcceleration,momentHip...
                                                    ,momentKnee,thigh_AccelerationX,thigh_AccelerationY,A4Hip_Angle,hip_Moment,ground_ReactionX...
                                                    ,ground_ReactionY,ankle_Angle,A3Thigh_AngAcceleration...
                                                    ,forceStruct)
%Calculate Fatigue Safety Factors
%Written by: Matthew Choi
%Last updated: Nov. 26, 2019
%Input: All objects  and accelerations necessary to calculate fatigue safety factors, and a force
%structure
%Output: Safety factor structure containing the components and their
%derivative safety factors. The safety factors are across 70 frames, so
%they must be mapped across 100 frames (ie. gait %) externally. 
%Description: Takes the component objects and the previously populated
%force structure and calculates the fatigue safety factors per component force, and
%returns in in a safety factor structure. 
%Notes: Finish debugging and check over with mainMEGAN from old code

%% Component Names %%
components = {'aBolt1' 'attachmentPlate1' 'bearingAA1' 'bearingCasingEF1' 'bottomBracket_L1' 'bottomBracket_R1' 'exoThigh1' 'uBar1'...
                                                    'exoShank1' 'foamThigh1' 'gasSpring1' 'gasSpringBolts1' 'hipFlexExBearing1'...
                                                    'hipMember1' 'hipMember21' 'hipString1' 'hipStopper1' 'hipStopperPin1' 'keys1'...
                                                    'kneePin1' 'pawl1' 'foamShank1' 'pawlPin1' 'pawlString1' 'plungerCasingEF1' 'plungerEF1'...
                                                    'plungerScrewEF1' 'ratchet1' 'shaftAA1' 'shelf1' 'thighScrew1' 'shankScrew1' 'topBracket_L1'...
                                                    'topBracket_R1' 'cBoot1'};
                                                
%% Create All Fatigue Safety Factor Structure Branches %%
%Description: Creates first degree branch of fatigue safety factor structure.
%Note: The 1 at the end of each component branch is used as a
%disambiguation from the actual object names. 
%Ex: [fatigueStruct.aBolt1, fatigueStruct.attachmentPlate1,...]
for i = 1:length(components)
    fatigueStruct.(components{i}) = [];
end

%% Fatigue Safety Factor Calculations %%
%Description: Calls the respective safety factor functions within each component's
%object class. The calculated safety factors are stored both in the fatigue safety
%factor structure, as well as within the classes themselves.
%Note: Input obj args to calculations (ie. first arg) use the passes
%objects; Input safety factor args use the structure property values.

%% Shelf %%
fatigueStruct.shelf1.n_fatigue_shelf = ...
    getn_fatigue(shelf, 0.8, 185000000, min(forceStruct.shelf1.forceGSYR));

%% Shaft AA %%
fatigueStruct.shaftAA1.n_fatigue_ShaftAA_R= ...
    ShaftAA_fatBendSF(shaftAA, max(forceStruct.hipMember1.FL2), absMax(forceStruct.shaftAA1.forceMember2_R)...
    ,max(forceStruct.hipMember21.torqueBearingABD_R));

%% Hip Member 2 %%
fatigueStruct.hipMember21.n_MG_hipMember2_R = ...
    getn_MG(hipMember2, 1, 0, 2.25, 90000000, max(forceStruct.hipMember21.torqueBearingABD_R), min(forceStruct.hipMember21.torqueBearingABD_R)...
    ,max(forceStruct.hipMember21.forceHip_R),min(forceStruct.hipMember21.forceHip_R));

%% Plunger EF %%
fatigueStruct.plungerEF1.n_fatigue_PlungerEF_R = ...
    getn_fatigue(plungerEF, 90000000, max(forceStruct.plungerEF1.forcePlunger_R), min(forceStruct.plungerEF1.forcePlunger_R), 15);

%% Hip Spring %%
fatigueStruct.hipSpring1.n_fatigue_hipSpring_R = ...
    hipSpring_fatigueSF(hipSpring, max(forceStruct.plungerEF1.forcePlunger_R));

%% Thigh %%
fatigueStruct.exoThigh1.n_fatigue_thigh_R = ...
    calcFatigue(exoThigh, max(forceStruct.exoThigh1.F_knee_x_R), min(forceStruct.exoThigh1.F_knee_x_R));

%% Ratchet %%
fatigueStruct.ratchet1.n_fatigue_ratchet_R = ...
    ratchet_fatigueSF(ratchet, max(forceStruct.exoThigh1.F_pawl_x_R));

%% Knee Bushing %%
% forceStruct.kneeBushing1.life_kneeBushing_R = ...
%     bushing_Life(kneeBushing, max(forceStruct.exoThigh1.F_knee_x_R), max(forceStruct.exoThigh1.F_knee_y_R));

%% Pawl Spring %%
fatigueStruct.pawlSpring1.n_fatigue_PawlSpring_R = ...
    pawlSpring_fatigueSF(pawlSpring, max(forceStruct.pawlSpring1.Fspring_R));

%% Pawl %%
fatigueStruct.pawl1.n_fatigue_Pawl_R = ...
    pawl_fatigueSF(pawl, max(forceStruct.pawl1.FpawlPinX_R));

%% Shank %%
fatigueStruct.exoShank1.n_fatigue_n_fatigue_Shank_R = ...
    calcFatigue(exoShank, max(forceStruct.exoThigh1.F_knee_x_R), min(forceStruct.exoThigh1.F_knee_x_R));

%% Ubar %%
fatigueStruct.uBar1.n_MG_ubar_R = ...
    Ubar_Fatigue(uBar, max(forceStruct.uBar1.F_cf_y_R), min(forceStruct.uBar1.F_cf_y_R),0.9,0); 

%% Compliant Boot %%
fatigueStruct.cBoot1.n_MG_cboot_R = ...
    CBoot_Fatigue(cBoot, 1, max(forceStruct.cBoot1.GRF_v_R));

%% Hip Stopper %%
fatigueStruct.hipStopper1.n_fatigue_hipStopper_R = ...
    hipStopper_fatigueSF(hipStopper, 0.1, max(abdAddHip_AngAcceleration));
end

