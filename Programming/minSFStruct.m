function [minSF,minSFArray,minStruct] = minSFStruct(sfStruct)
components = {'aBolt1' 'attachmentPlate1' 'bearingAA1' 'bearingCasingEF1' 'bottomBracket_L1' 'bottomBracket_R1' 'exoThigh1' 'uBar1'...
                                                    'exoShank1' 'foamThigh1' 'gasSpring1' 'gasSpringBolts1' 'hipFlexExBearing1'...
                                                    'hipMember1' 'hipMember21' 'hipString1' 'hipStopper1' 'hipStopperPin1' 'keys1'...
                                                    'kneePin1' 'pawl1' 'foamShank1' 'pawlPin1' 'pawlString1' 'plungerCasingEF1' 'plungerEF1'...
                                                    'plungerScrewEF1' 'ratchet1' 'shaftAA1' 'shelf1' 'thighScrew1' 'shankScrew1' 'topBracket_L1'...
                                                    'topBracket_R1' 'cBoot1'};
for i = 1:length(components)
    minStruct.(components{i}) = [];
end

%% Shelf %%
minStruct.shelf1.n_stress_shelf = min(sfStruct.shelf1.n_stress_shelf);
minSF(1) = min(sfStruct.shelf1.n_stress_shelf);

%% Top Bracket %%
minStruct.topBracket_R1.n_stress_Bracket1_R = min(sfStruct.topBracket_R1.n_stress_Bracket1_R);
minSF(2) = min(sfStruct.topBracket_R1.n_stress_Bracket1_R);

%% Gas Spring Bolts %%
minStruct.gasSpringBolts1.n_GasSpringBolt1_R = min(sfStruct.gasSpringBolts1.n_GasSpringBolt1_R);
minSF(3) = min(sfStruct.gasSpringBolts1.n_GasSpringBolt1_R);

%% Bottom Bracket %%
minStruct.bottomBracket_R1.n_bottomBracket_R = min(sfStruct.bottomBracket_R1.n_bottomBracket_R);
minSF(4) = min(sfStruct.bottomBracket_R1.n_bottomBracket_R);

%% Hip Member1 %%
minStruct.hipMember1.n_stress = min(sfStruct.hipMember1.n_stress);
minSF(5) = min(sfStruct.hipMember1.n_stress);

%% Bearing AA %%
minStruct.bearingAA1.n_capacity_BearingAA_R = min(sfStruct.bearingAA1.n_capacity_BearingAA_R);
minSF(6) = min(sfStruct.bearingAA1.n_capacity_BearingAA_R);

%% Hip Stopper Pin %%
minStruct.hipStopperPin1.n_shear_hipStopper_R = min(sfStruct.hipStopperPin1.n_shear_hipStopper_R);
minSF(7) = min(sfStruct.hipStopperPin1.n_shear_hipStopper_R);

%% Hip Stopper
minStruct.hipStopper1.n_stress_hipStopper_R = min(sfStruct.hipStopper1.n_stress_hipStopper_R);
minSF(8) = min(sfStruct.hipStopper1.n_stress_hipStopper_R);

%% Hip Member 2 %%
minStruct.hipMember21.n_stress_ShaftAA_R = min(sfStruct.hipMember21.n_stress_ShaftAA_R);
minStruct.hipMember21.n_stress_keys_R = min(sfStruct.hipMember21.n_stress_keys_R);
minStruct.hipMember21.n_stress_HipMember2_R = min(sfStruct.hipMember21.n_stress_HipMember2_R);
minSF(9) = min(sfStruct.hipMember21.n_stress_ShaftAA_R);
minSF(10) = min(sfStruct.hipMember21.n_stress_keys_R);
minSF(11) = min(sfStruct.hipMember21.n_stress_HipMember2_R);

%% Plunger Screw EF Right %%
minStruct.plungerScrewEF1.n_stress_PlungerEF_R = min(sfStruct.plungerScrewEF1.n_stress_PlungerEF_R);
minStruct.plungerScrewEF1.n_stress_PlungerScrew_R = min(sfStruct.plungerScrewEF1.n_stress_PlungerScrew_R);
minStruct.plungerScrewEF1.n_capacity_hipBearingEF_R = min(sfStruct.plungerScrewEF1.n_capacity_hipBearingEF_R);
minStruct.plungerScrewEF1.n_shear_hipSpring_R = min(sfStruct.plungerScrewEF1.n_shear_hipSpring_R);
minSF(12) = min(sfStruct.plungerScrewEF1.n_stress_PlungerEF_R);
minSF(13) = min(sfStruct.plungerScrewEF1.n_stress_PlungerScrew_R);
minSF(14) = min(sfStruct.plungerScrewEF1.n_capacity_hipBearingEF_R);
minSF(15) = min(sfStruct.plungerScrewEF1.n_shear_hipSpring_R);

%% Bearing Casing EF %%
minStruct.bearingCasingEF1.n_stress_BearingCasingScrew_R = min(sfStruct.bearingCasingEF1.n_stress_BearingCasingScrew_R);
minSF(16) = min(sfStruct.bearingCasingEF1.n_stress_BearingCasingScrew_R);

%% Attachment Plate %%
minStruct.attachmentPlate1.n_attachment_R = min(sfStruct.attachmentPlate1.n_attachment_R);
minSF(17) = min(sfStruct.attachmentPlate1.n_attachment_R);

%% Thigh %%
minStruct.exoThigh1.n_stress_thigh_R = min(sfStruct.exoThigh1.n_stress_thigh_R);
minStruct.exoThigh1.n_foamTH_R = min(sfStruct.exoThigh1.n_foamTH_R);
%minStruct.exoThigh1.n_failure_kneeBushing_R = min(sfStruct.exoThigh1.n_failure_kneeBushing_R);
minStruct.exoThigh1.n_shear_kneePin_R = min(sfStruct.exoThigh1.n_shear_kneePin_R);
minStruct.exoThigh1.n_bending_ratchet_R = min(sfStruct.exoThigh1.n_bending_ratchet_R);
minSF(18) = min(sfStruct.exoThigh1.n_stress_thigh_R);
minSF(19) = min(sfStruct.exoThigh1.n_foamTH_R);
%minSF(20) = min(sfStruct.exoThigh1.n_failure_kneeBushing_R);
minSF(21) = min(sfStruct.exoThigh1.n_shear_kneePin_R);
minSF(22) = min(sfStruct.exoThigh1.n_bending_ratchet_R);

%% Pawl Spring %%
minStruct.pawlSpring1.n_shear_Fspring_R = min(sfStruct.pawlSpring1.n_shear_Fspring_R);
minSF(23) = min(sfStruct.pawlSpring1.n_shear_Fspring_R);

%% Pawl %%
minStruct.pawl1.n_yield_Pawl_R = min(sfStruct.pawl1.n_yield_Pawl_R);
minStruct.pawl1.n_shear_pawlPin_R = min(sfStruct.pawl1.n_shear_pawlPin_R);
minSF(24) = min(sfStruct.pawl1.n_yield_Pawl_R);
minSF(25) = min(sfStruct.pawl1.n_shear_pawlPin_R);

%% Pawl String %%
minStruct.pawlString1.n_rupture_PawlString = min(sfStruct.pawlString1.n_rupture_PawlString);
minSF(26) = min(sfStruct.pawlString1.n_rupture_PawlString);

%% Shank %%
minStruct.exoShank1.nmin_shank_R = min(sfStruct.exoShank1.nmin_shank_R);
minSF(27) = min(sfStruct.exoShank1.nmin_shank_R);

%% Ubar %%
minStruct.uBar1.n_stress_ubar_R = min(sfStruct.uBar1.n_stress_ubar_R);
minStruct.uBar1.n_bolt_Abolt_R = min(sfStruct.uBar1.n_bolt_Abolt_R);
minSF(28) = min(sfStruct.uBar1.n_stress_ubar_R);
minSF(29) = min(sfStruct.uBar1.n_bolt_Abolt_R);

%% Compliant Boot %%
minStruct.cBoot1.n_DE_Cboot_R = min(sfStruct.cBoot1.n_DE_Cboot_R);
minSF(30) = min(sfStruct.cBoot1.n_DE_Cboot_R);

%% Clean Up %%
minSFArray = minSF;
minSF = min(minSF);


end

