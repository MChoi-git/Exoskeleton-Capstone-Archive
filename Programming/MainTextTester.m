function [forceStruct,sfStruct,fatigueStruct,ground_ReactionX,ground_ReactionY,hipPowerWithEXO,hipPowerNoEXO,footclearance,GRF_v,GRF_fa,finalLog] = ...
    MainTextTester(UserHgui,UserMgui,Hip_Depthgui)
%CAD Gait Cycle Analysis Program 
%Input: Nothing
%Output: Safety Factor Log Files
%Written by: Matthew Choi 
%Last update: Dec. 2, 2019
%Description: Main script which creates and manages objects. Populates
%force and safety factor structures for parameterization checks. Sends all
%data to log files and the GUI.
%Notes: Most current version. Implement LOG file export to GUI. To run this
%program, open GUI_RUNME and press F5 or click the run button in the
%toolbar. 
%Changelog: Finish log exporting

%% Create Pathing %%
addpath(genpath('NEWrawAccelerationPkg'));
addpath(genpath('Text files'));

%% Variables %%
pFlag = true; %Parameterization loop flag
UserH = UserHgui;
UserM = UserMgui;
Hip_Depth = Hip_Depthgui/100;
% UserH = 156;
% UserM = 85.52;
% Hip_Depth = 26/100;

%% Converting Frame To Gait Percentage %%
j = 1;
gaitPercentage = zeros(70,1);
for i = 0:(100/69):100
    gaitPercentage(j) = i;
    j = j+1;
end

%% Component Object Creation %%
aBolt = ABolt(940000000, 0.005);
%YS, ABolt_D
attachmentPlate = AttachmentPlate(4000000,0.003,0.008,0.11,0.0028);
%ys,t_attPlate,d_casingScrew,R_outer,h_plate
bearingAA = BearingAA(10.6); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%C_selected
bearingCasingEF = BearingCasingEF(2700,0.08,370000000); %CHANGED ARGS
%volume,density,diameter,ys
bottomBracket_L = BottomBracket(150000000,0.001,0.02,0.02,0.025);
bottomBracket_R = BottomBracket(150000000,0.001,0.02,0.02,0.025);
%mat_Sy, t_bottomBracket, l_bracketGasSpr, l_bracketBottom, w_bottomBracket
%boxString = BoxString(79000000,179000000,0.75); %REDACTED
%mat_Sy, mat_Su, Cs ASTM class 25 gray iron
%mat_Sy, mat_Su, r_inner, r_outer, l_bushing
exoThigh = ExoThigh(UserH, 0.006);
%height,t_thigh
uBar = UBar(UserH,2690,90000000,34000000,0.001,0.02,0.006,70000000000); %CHANGED ARGS
exoShank = ExoShank(UserH,exoThigh.t_thigh,uBar.Ubar_T_bottom); %uBar.Ubar_T_nominal
%height, Ubar Nominal Thickness
foamThigh = Foam(0, exoThigh.t_thigh, exoThigh.w_thigh); %CHANGED ARGS
gasSpring = GasSpring(0.15,0.008);
%length,diameter
gasSpringBolts = GasSpringBolts(517000000);
%YS
%hBoltString = HBoltString(415000000,690000000,0.75); REDACTED
%mat_Sy, mat_Su, Cs 303 stainless steel, cold drawn bar 
hipFlexExBearing = HipFlexExBearing(3350);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%C_selected
hipMember = HipMember(2690, 0.02, 0.10, 0.2, 0.12, 0.042, UserH, 34000000); %CHANGED ARGS
%density,volume,rgs2L1,rhL1,rgs1L1,rL2L1, hipMember_T, hipMember_L_Small, YS
hipMember2 = HipMember2(0.07,0.10,0.07,19250,0.02,0.10,0.02,34000000, Hip_Depth);
%cb,ch,cw,crho,m,thickness,width,diameter,YS
hipSpring = HipSpring(1600000000,0.0021,0.025);
%mat_Su, D_wire, D_coil
hipStopper = HipStopper(1070,29600000,29800000,0.04,0.01,0.01,0.02,0.01);
%density, mat_Sy, mat_Su, l_stopper, w_stopper, t_stopper, r_outer, r_inner
hipStopperPin = HipStopperPin(29600000,29800000,0.0508,0.00318);
%mat_Sy, mat_Su, L_pin, R_pin
keys = Keys(370000000,0.036,0.005,0.005,0.01);
%mat_Sy, l_Key, t_Key, h_Key, r_shaft
%kneeBushing = KneeBushing(365000000,415000000); REDACTED
%mat_Sy, mat_Su UNS C22000
kneePin = KneePin(172000000,241000000,exoThigh.t_thigh); %CHANGED ARGS
%mat_Sy, mat_Su AISI1040
pawl = Pawl(353400000,518800000, 0.46);
%mat_Sy, mat_Su, Cs AISI1040
foamShank = Foam(pawl.d_pawl2string, exoShank.t_total, exoShank.w_shank); %CHANGED ARGS
%d_hole
pawlPin = PawlPin(379000000,448000000);
%mat_Sy, mat_Su 
%%NEW STUFF
%%%%%%%%%%%
pawlSpring = PawlSpring(2600000000,0.009,0.004);
%mat_Su, x_string, d_pawl2string, d_pawl2spring ASTM A228

plungerCasingEF = PlungerCasingEF(0.00003273,2700);
%volume,density
plungerEF = PlungerEF(2690,0.2327,0.375,0.1765,0.095,0.0543,0.002,0.0792,34000000,0.00265,378,0.06, exoThigh.t_thigh);%!!!!!!!!!!!
%volume,density,member2ext,counterweightext,weightext,plungerx,plungery,thickness,height,YS,T_PlungerHousing,springConstant,width!!!!!
plungerScrewEF = PlungerScrewEF(0.008,276000000,0.005,0.005,0.05);
%diameter,ys,plungerth,rubberth,barwidth
ratchet = Ratchet(172000000, 241000000, 0.75, exoThigh.w_thigh, exoThigh.t_thigh);
%mat_Sy, mat_Su, Cs AISI 1040
shaftAA = ShaftAA(0.01,0.08,7500,0.05,0.2871, 0.0471,0.1671, 0.3342,9.43,710000000,1110000000,555000000,0.53);
%radius, length, density, rm2abd, rgs1b, rgs2b, rcb, rl2b, weightCounter,mat_Sy, mat_Su, mat_Ssu, Cs
shelf = Shelf(0.28,0.30,0.006,2780,50,23.58,76000000);
%length,width,thickness,density,bpmass,theta,yeildSTR
thighScrew = ThighShankScrew(0.0056, exoThigh.t_thigh, 0.0025, 2);
%LS_memberlength, t, t_min, qty
shankScrew = ThighShankScrew(0.0047, exoShank.t_total, 0.0025, 2);
%LS_memberlength, t, t_min, qty
topBracket_L = TopBracket(76000000,0.001,0.02,0.02,0.025);
topBracket_R = TopBracket(76000000,0.001,0.02,0.02,0.025);
%YS
cBoot = CBoot((UserH/100),1550,10000000,8200000,uBar,0.001); %CHANGED ARGS
%HEIGHT, CBoot_density, CBoot_UTS, CBoot_YS, CBoot_L_shoe, Ubarobj
pawlString = PawlString(500,0.0735,exoThigh,exoShank,cBoot,uBar); %breakload, y_ankle, thigh,shank,cBoot,uBar
%vBoltString = VBoltString(415000000,690000000,0.75); REDACTED
%mat_Sy, mat_Su, Cs 

%% Parallel Axis Theorem Hip %%
m_thigh = UserM * 0.1;
L_thigh = (0.53-0.285) * UserH / 100;
r_gyration = 0.323 * L_thigh;
I_thigh = m_thigh * (r_gyration ^ 2);
r_proximal = 0.433 * L_thigh;
I_hip = I_thigh + (m_thigh * (r_proximal ^ 2));

%% Parallel Axis Theorem Knee %%
m_shank = UserM * 0.0465;
L_shank = (0.285 - 0.039) * UserH / 100;
r_gyration = 0.302 * L_shank;
I_shank = m_shank * (r_gyration ^ 2);
r_proximal = 0.433 * L_shank;
I_knee = I_shank + (m_shank * (r_proximal ^ 2));

%% Excel Acceleration Population %%
%Note: Add in knee angular acceleration from A3
RAWabdAddHip_AngAcceleration = xlsread('Hip Abd Add angular accelerations.csv'); %in package
RAWflxExtHip_AngAcceleration = xlsread('Hip Flex Ext angular accelerations.xlsx'); %in package
%RAWknee_AngAcceleration = xlsread('xxx');
%RAWankle_AngAcceleration = xlsread('xxx');
RAWshank_Acceleration = xlsread('Shank linear xy and angular accelerations.xlsx');
%RAWthigh_Acceleration = xlsread('xxx');
RAWcom_Acceleration = xlsread('COMv3.xlsx'); %in package
RAWfoot_Acceleration = xlsread('Foot linear accelerations xy.xlsx'); %in package
RAWgreaterTrochanter_Acceleration = xlsread('greater trochanter linear accelerations xy.xlsx'); %in package
RAWA4Hip_Acceleration = xlsread('Hip Flex Ext angular accelerations.xlsx'); %in package, same as flx ext hip
RAWthigh_Acceleration = xlsread('Thigh linear xy accelerations.xlsx');
RAWA4Hip_Angle = xlsread('A4 hip angle.xlsx');
RAWhip_Moment = xlsread('Hip moment.xlsx');
RAWground_Reaction = xlsread('Ground reaction forces.xlsx');
RAWankle_Angle = xlsread('Ankle Angle A4.xlsx');
RAWA3Thigh_AngAcceleration = xlsread('Thigh linear xy accelerations.xlsx');
RAWA4Hip_Omega = xlsread('A4-hip-omega.xlsx');
RAWfootClearances = xlsread('Normalized Foot Clearances.xlsx');

abdAddHip_AngAcceleration = zeros(1,70);
flxExtHip_AngAcceleration = zeros(1,70);
shank_AccelerationX = zeros(1,70);
shank_AccelerationY = zeros(1,70);
shank_AngAcceleration = zeros(1,70);
com_Acceleration = zeros(1,70);
foot_AccelerationX = zeros(1,70);
foot_AccelerationY = zeros(1,70);
greaterTrochanter_AccelerationX = zeros(1,70);
greaterTrochanter_AccelerationY = zeros(1,70);
A4Hip_Acceleration = zeros(1,70);
momentHipACC = zeros(1,70);
momentKnee = zeros(1,70);
thigh_AccelerationX = zeros(1,70);
thigh_AccelerationY = zeros(1,70);
A4Hip_Angle = zeros(1,70);
hip_Moment = zeros(1,70);
ground_ReactionX = zeros(1,70);
ground_ReactionY = zeros(1,70);
ankle_Angle = zeros(1,70);
A3Thigh_AngAcceleration = zeros(1,70);
Hip_Omega = zeros(1,70);
hipPowerWithEXO = zeros(1,70);
hipPowerNoEXO = zeros(1,70);
ground_ReactionXExo = zeros(1,70);
ground_ReactionYExo = zeros(1,70);
footClearances = zeros(2,70);

for i = 1:70
    abdAddHip_AngAcceleration(i) = RAWabdAddHip_AngAcceleration(i,2);
    flxExtHip_AngAcceleration(i) = RAWflxExtHip_AngAcceleration(i,2);
    %knee_AngAcceleration = RAWknee_AngAcceleration(i,2);
    %ankle_AngAcceleration = RAWankle_AngAcceleration(i,2);
    shank_AccelerationX(i) = RAWshank_Acceleration(i,2);
    shank_AccelerationY(i) = RAWshank_Acceleration(i,3);
    shank_AngAcceleration(i) = RAWshank_Acceleration(i,4);
    %thigh_Acceleration = RAWthighAcceleration(i,2);
    com_Acceleration(i) = RAWcom_Acceleration(i,3);
    foot_AccelerationX(i) = RAWfoot_Acceleration(i,2);
    foot_AccelerationY(i) = RAWfoot_Acceleration(i,3);
    greaterTrochanter_AccelerationX(i) = RAWgreaterTrochanter_Acceleration(i,2);
    greaterTrochanter_AccelerationY(i) = RAWgreaterTrochanter_Acceleration(i,3);
    A4Hip_Acceleration(i) = RAWA4Hip_Acceleration(i,2);
    momentHipACC(i) = RAWthigh_Acceleration(i,3) * I_hip;
    momentKnee(i) = RAWshank_Acceleration(i,3) * I_knee;
    thigh_AccelerationX(i) = RAWthigh_Acceleration(i,2);
    thigh_AccelerationY(i) = RAWthigh_Acceleration(i,3);
    A4Hip_Angle(i) = RAWA4Hip_Angle(i,1);
    hip_Moment(i) = RAWhip_Moment(i,1);
    ankle_Angle(i) = RAWankle_Angle(i,1);
    A3Thigh_AngAcceleration(i) = RAWA3Thigh_AngAcceleration(i,3);
    ground_ReactionX(i) = RAWground_Reaction(i,3) * (UserM + 50);
    ground_ReactionY(i) = RAWground_Reaction(i,4) * (UserM + 50);
    Hip_Omega(i) = RAWA4Hip_Omega(i,1);
    ground_ReactionXExo(i) = RAWground_Reaction(i,3) * (UserM);
    ground_ReactionYExo(i) = RAWground_Reaction(i,4) * (UserM);
    footClearancesHeel(i) = RAWfootClearances(i,1) * UserH; %Foot clearances not for our height case yet
    footClearancesToe(i) = RAWfootClearances(i,2) * UserH;
end

flxExtHip_AngAcceleration = flxExtHip_AngAcceleration(:);   %Hip flexion/extension angular acceleration
%knee_AngAcceleration = knee_AngAcceleration(:);             %Knee angular acceleration
%ankle_AngAcceleration = ankle_AngAcceleration(:);           %Ankle angular acceleration
shank_AccelerationX = shank_AccelerationX(:);                 %Shank acceleration
shank_AccelerationY = shank_AccelerationY(:);
shank_AngAcceleration = shank_AngAcceleration(:);
%thigh_Acceleration = thigh_Acceleration(:);                 %Thigh acceleration
foot_AccelerationX = foot_AccelerationX(:);                   %Foot acceleration YES
foot_AccelerationY = foot_AccelerationY(:);
A4Hip_Acceleration = A4Hip_Acceleration(:);                 %Section A4 hip acceleration
greaterTrochanter_AccelerationX = greaterTrochanter_AccelerationX(:);
greaterTrochanter_AccelerationY = greaterTrochanter_AccelerationY(:);
com_Acceleration = com_Acceleration(:);
abdAddHip_AngAcceleration = abdAddHip_AngAcceleration(:);
momentHipACC = momentHipACC(:);
momentKnee = momentKnee(:);
thigh_AccelerationX = thigh_AccelerationX(:);
thigh_AccelerationY = thigh_AccelerationY(:);
A4Hip_Angle = A4Hip_Angle(:);
hip_Moment = hip_Moment(:);
ground_ReactionX = ground_ReactionX(:);
ground_ReactionY = ground_ReactionY(:);
ankle_Angle = ankle_Angle(:);
A3Thigh_AngAcceleration = A3Thigh_AngAcceleration(:);
Hip_Omega = Hip_Omega(:);
ground_ReactionXExo = ground_ReactionXExo(:);
ground_ReactionYExo = ground_ReactionYExo(:);
footClearancesHeel = footClearancesHeel(:);
footClearancesToe = footClearancesToe(:);

%% Finding Exo Ground Clearances %%
footclearance = min([min(footClearancesHeel),min(footClearancesToe)]);

%% Curve Fitting %%
fit_comAngle = fit(gaitPercentage,com_Acceleration,'fourier8'); %Rename the angular acceleration to angle later
comAngleToVelocity = differentiate(fit_comAngle,gaitPercentage);
fit_comVelocity = fit(gaitPercentage,comAngleToVelocity,'fourier8');
com_Acceleration = differentiate(fit_comVelocity,gaitPercentage);

fit_abdAddAngle = fit(gaitPercentage,abdAddHip_AngAcceleration,'fourier8'); %Rename the angular acceleration to angle later
abdAddAngleToVelocity = differentiate(fit_abdAddAngle,gaitPercentage);
fit_abdAddVelocity = fit(gaitPercentage,abdAddAngleToVelocity,'fourier8');
abdAddHip_AngAcceleration = differentiate(fit_abdAddVelocity,gaitPercentage);

abdAddHip_AngAcceleration = abdAddHip_AngAcceleration(:);   %Hip abduction/adduction angularacceleration YES
com_Acceleration = com_Acceleration(:);                     %COM acceleration YES

%% Thigh Parameterization Values%%
limitingSF = 'n_fatigue_ratchet_R';
limitingSFValue = 2;
limitingSFComponent = 'ratchet1';

%% Switch To Turn Off Parameterization
% pSwitch = true;
% pSwitch2 = true;

%% Thigh Parameterization Loop %%
% Initial dimension values %
newThighThickness = exoThigh.t_thigh;
while(pFlag == true)
    %disp('p1');
    [forceStruct,sfStruct,fatigueStruct,pFlag] = ... %Generate structures
        Parameterize(aBolt,attachmentPlate,bearingAA,bearingCasingEF,bottomBracket_L,bottomBracket_R...
                                                    ,exoThigh,uBar,exoShank,foamThigh,gasSpring,gasSpringBolts...
                                                    ,hipFlexExBearing,hipMember,hipMember2,hipSpring,hipStopper,hipStopperPin...
                                                    ,keys,kneePin,pawl,foamShank,pawlPin,pawlString,pawlSpring,plungerCasingEF...
                                                    ,plungerEF,plungerScrewEF,ratchet,shaftAA,shelf,thighScrew,shankScrew,topBracket_L...
                                                    ,topBracket_R,cBoot... 
                                                    ,flxExtHip_AngAcceleration,shank_AccelerationX,shank_AccelerationY,shank_AngAcceleration...
                                                    ,foot_AccelerationX,foot_AccelerationY,A4Hip_Acceleration,greaterTrochanter_AccelerationX...
                                                    ,greaterTrochanter_AccelerationY,com_Acceleration,abdAddHip_AngAcceleration,momentHipACC...
                                                    ,momentKnee,thigh_AccelerationX,thigh_AccelerationY,A4Hip_Angle,hip_Moment,ground_ReactionX...
                                                    ,ground_ReactionY,ankle_Angle,A3Thigh_AngAcceleration,UserM...
                                                    ,limitingSF,limitingSFValue,limitingSFComponent);
    [minSF,minSFArray,minStruct] = minSFStruct(sfStruct); %Populate structure containing minimum safety factors
    if(pFlag == true) %If parameterization needs to continue, increase dimensions
        
        % New Parameterized Values %
        newThighThickness = newThighThickness + 0.0005;
        
        % New Object Creation %
        exoThigh = ExoThigh(UserH, newThighThickness);
        exoShank = ExoShank(UserH,exoThigh.t_thigh,uBar.Ubar_T_bottom);
        plungerEF = PlungerEF(2690,0.2327,0.375,0.1765,0.095,0.0543,0.002,0.0792,34000000,0.00265,378,0.06, exoThigh.t_thigh);
        pawlString = PawlString(500,0.0735,exoThigh,exoShank,cBoot,uBar);
        hipMember = HipMember(2690, 0.02, 0.10, 0.2, 0.12, 0.042, UserH, 34000000); 
        hipMember2 = HipMember2(0.07,0.10,0.07,19250,0.02,0.10,0.04,34000000, Hip_Depth);
        foamShank = Foam(pawl.d_pawl2string, exoShank.t_total, exoShank.w_shank);
        foamThigh = Foam(0, exoThigh.t_thigh, exoThigh.w_thigh);
        ratchet = Ratchet(172000000, 241000000, 0.75, exoThigh.w_thigh, exoThigh.t_thigh);
        kneePin = KneePin(172000000,241000000,exoThigh.t_thigh);
    end
end
pFlag = true; %Reset parameterization flag

% %% uBar Parameterization Values %%
limitingSF = 'n_bolt_Abolt_R';
limitingSFValue = 2;
limitingSFComponent = 'uBar1';

%% uBar Parameterization Loop %%
% Initial dimension values %
newUBarTNominal = uBar.Ubar_T_nominal;
%Notes: Verify with Megan the parameterized dimension

while(pFlag == true)
    %disp('p2')
    [forceStruct,sfStruct,fatigueStruct,pFlag] = ... %Generate Structures
        Parameterize(aBolt,attachmentPlate,bearingAA,bearingCasingEF,bottomBracket_L,bottomBracket_R...
                                                    ,exoThigh,uBar,exoShank,foamThigh,gasSpring,gasSpringBolts...
                                                    ,hipFlexExBearing,hipMember,hipMember2,hipSpring,hipStopper,hipStopperPin...
                                                    ,keys,kneePin,pawl,foamShank,pawlPin,pawlString,pawlSpring,plungerCasingEF...
                                                    ,plungerEF,plungerScrewEF,ratchet,shaftAA,shelf,thighScrew,shankScrew,topBracket_L...
                                                    ,topBracket_R,cBoot... 
                                                    ,flxExtHip_AngAcceleration,shank_AccelerationX,shank_AccelerationY,shank_AngAcceleration...
                                                    ,foot_AccelerationX,foot_AccelerationY,A4Hip_Acceleration,greaterTrochanter_AccelerationX...
                                                    ,greaterTrochanter_AccelerationY,com_Acceleration,abdAddHip_AngAcceleration,momentHipACC...
                                                    ,momentKnee,thigh_AccelerationX,thigh_AccelerationY,A4Hip_Angle,hip_Moment,ground_ReactionX...
                                                    ,ground_ReactionY,ankle_Angle,A3Thigh_AngAcceleration,UserM...
                                                    ,limitingSF,limitingSFValue,limitingSFComponent);
    [minSF,minSFArray,minStruct] = minSFStruct(sfStruct);
    if(pFlag == true) %If parameterization needs to continue, increase dimensions
        % New Parameterized Values %
        newUBarTNominal = newUBarTNominal + 0.0005;
        
        % New Object Creation %
        uBar = UBar(UserH,2690,90000000,34000000,newUBarTNominal,0.02,0.006,70000000000);
        exoShank = ExoShank(UserH,exoThigh.t_thigh,uBar.Ubar_T_bottom);
%         plungerEF = PlungerEF(2690,0.2327,0.375,0.1765,0.095,0.0543,0.002,0.0792,34000000,0.00265,378,0.06, exoThigh.t_thigh);
        pawlString = PawlString(500,0.0735,exoThigh,exoShank,cBoot,uBar);
%         hipMember = HipMember(2690, 0.02, 0.10, 0.2, 0.12, 0.042, UserH, 34000000); 
%         hipMember2 = HipMember2(0.07,0.10,0.07,19250,0.02,0.10,0.04,34000000, Hip_Depth);
        foamShank = Foam(pawl.d_pawl2string, exoShank.t_total, exoShank.w_shank);
        foamThigh = Foam(0, exoThigh.t_thigh, exoThigh.w_thigh);
        ratchet = Ratchet(172000000, 241000000, 0.75, exoThigh.w_thigh, exoThigh.t_thigh);
        kneePin = KneePin(172000000,241000000,exoThigh.t_thigh);
    end
end
pFlag = true;

%% cBoot Parameterization Values %%
limitingSF = 'n_DE_Cboot_R';
limitingSFValue = 2;
limitingSFComponent = 'cBoot1';

%% cBoot Parameterization Loop %%
% Initial dimension values %
newCBootLength2 = cBoot.length2;
%Notes: Verify with Megan the parameterized dimension
while(pFlag == true)
    %disp('p3');
    [forceStruct,sfStruct,fatigueStruct,pFlag] = ... %Generate Structures
        Parameterize(aBolt,attachmentPlate,bearingAA,bearingCasingEF,bottomBracket_L,bottomBracket_R...
                                                    ,exoThigh,uBar,exoShank,foamThigh,gasSpring,gasSpringBolts...
                                                    ,hipFlexExBearing,hipMember,hipMember2,hipSpring,hipStopper,hipStopperPin...
                                                    ,keys,kneePin,pawl,foamShank,pawlPin,pawlString,pawlSpring,plungerCasingEF...
                                                    ,plungerEF,plungerScrewEF,ratchet,shaftAA,shelf,thighScrew,shankScrew,topBracket_L...
                                                    ,topBracket_R,cBoot... 
                                                    ,flxExtHip_AngAcceleration,shank_AccelerationX,shank_AccelerationY,shank_AngAcceleration...
                                                    ,foot_AccelerationX,foot_AccelerationY,A4Hip_Acceleration,greaterTrochanter_AccelerationX...
                                                    ,greaterTrochanter_AccelerationY,com_Acceleration,abdAddHip_AngAcceleration,momentHipACC...
                                                    ,momentKnee,thigh_AccelerationX,thigh_AccelerationY,A4Hip_Angle,hip_Moment,ground_ReactionX...
                                                    ,ground_ReactionY,ankle_Angle,A3Thigh_AngAcceleration,UserM...
                                                    ,limitingSF,limitingSFValue,limitingSFComponent);
    [minSF,minSFArray,minStruct] = minSFStruct(sfStruct);
    if(pFlag == true) %If parameterization needs to continue, increase dimensions
        
        % New Parameterized Values %
        newCBootLength2 = newCBootLength2 + 0.0005;
        
        % New Object Creation %
        exoThigh = ExoThigh(UserH, newThighThickness);
        cBoot = CBoot((UserH/100),1550,10000000,8200000,uBar,newCBootLength2);
        exoShank = ExoShank(UserH,exoThigh.t_thigh,uBar.Ubar_T_bottom);
%         plungerEF = PlungerEF(2690,0.2327,0.375,0.1765,0.095,0.0543,0.002,0.0792,34000000,0.00265,378,0.06, exoThigh.t_thigh);
        pawlString = PawlString(500,0.0735,exoThigh,exoShank,cBoot,uBar);
%         hipMember = HipMember(2690, 0.02, 0.10, 0.2, 0.12, 0.042, UserH, 34000000); 
%         hipMember2 = HipMember2(0.07,0.10,0.07,19250,0.02,0.10,0.04,34000000, Hip_Depth);
        foamShank = Foam(pawl.d_pawl2string, exoShank.t_total, exoShank.w_shank);
        foamThigh = Foam(0, exoThigh.t_thigh, exoThigh.w_thigh);
        ratchet = Ratchet(172000000, 241000000, 0.75, exoThigh.w_thigh, exoThigh.t_thigh);
        kneePin = KneePin(172000000,241000000,exoThigh.t_thigh);
    end
end

GRF_v = zeros(1,70);
GRF_fa = zeros(1,70);
length(GRF_v)
length(ground_ReactionYExo)
length(forceStruct.cBoot1.GRF_vexo_R)
%% Calculating Hip Powers %%
for i= 1:70
    hipPowerWithEXO(i) = (momentHipACC(i)-forceStruct.plungerEF1.torque_Bearing_R(i))*Hip_Omega(i);
    hipPowerNoEXO(i) = momentHipACC(i)*Hip_Omega(i);

    GRF_v(i) = ground_ReactionYExo(i) + forceStruct.cBoot1.GRF_vexo_R(i); %Add these to the function call
    GRF_fa(i) = ground_ReactionXExo(i) + forceStruct.cBoot1.GRF_fa_R(i);
end

%% Read and Print To Solidworks Source Text File %%
components = {'CBoot' 'Hip Member 1' 'Hip Member 2' 'KneePin'...
    'Left Plunger' 'PawlString' 'Right Plunger'... %Ask Jen about plunger rubber
    'Shaft' 'Shank' 'Thigh' 'Ubar'};
[rawText,dimensionNames,dimMagnitudeIndex,dimMagnitudeLength,dimMagnitude,export] = ...
    TextOut(cBoot,'CBoot');
[rawText,dimensionNames,dimMagnitudeIndex,dimMagnitudeLength,dimMagnitude,export] = ...
    TextOut(hipMember,'Hip Member 1');
[rawText,dimensionNames,dimMagnitudeIndex,dimMagnitudeLength,dimMagnitude,export] = ...
    TextOut(hipMember2,'Hip Member 2');
[rawText,dimensionNames,dimMagnitudeIndex,dimMagnitudeLength,dimMagnitude,export] = ...
    TextOut(kneePin,'KneePin');
[rawText,dimensionNames,dimMagnitudeIndex,dimMagnitudeLength,dimMagnitude,export] = ...
    TextOut(plungerEF,'Left Plunger');
[rawText,dimensionNames,dimMagnitudeIndex,dimMagnitudeLength,dimMagnitude,export] = ...
    TextOut(pawlString,'PawlString');
[rawText,dimensionNames,dimMagnitudeIndex,dimMagnitudeLength,dimMagnitude,export] = ...
    TextOut(plungerEF,'Right Plunger');
[rawText,dimensionNames,dimMagnitudeIndex,dimMagnitudeLength,dimMagnitude,export] = ...
    TextOut(exoShank,'Shank');
[rawText,dimensionNames,dimMagnitudeIndex,dimMagnitudeLength,dimMagnitude,export] = ...
    TextOut(exoThigh,'Thigh');
[rawText,dimensionNames,dimMagnitudeIndex,dimMagnitudeLength,dimMagnitude,export] = ...
    TextOut(uBar,'Ubar');

%% Generate Log File Data %%
[logSFNames,logSFValues,finalLog] = LogOut(sfStruct,fatigueStruct);




%% Plots %%
% plot(gaitPercentage,footClearancesHeel);
% title('Heel Clearance');
% xlabel('Gait Percentage');
% ylabel('Distance (cm)');
% 
% figure;
% plot(gaitPercentage,footClearancesToe);
% title('Toe Clearance');
% xlabel('Gait Percentage');
% ylabel('Distance (cm)');

end
