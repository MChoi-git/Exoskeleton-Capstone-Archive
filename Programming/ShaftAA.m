classdef ShaftAA < handle

    properties
        shaftAA_Radius;
        shaftAA_Length;
        shaftAA_Density;
        shaftAA_Weight;
        
        moment_Inertia;
        
        force_Member2;
        force_Hip;
        force_CounterWeight;
        force_BushingY;
        torque_BearingAbd;
        
        radius_Member2Abd;
        radius_GS1Bearing;
        radius_GS2Bearing;
        radius_CenterBearing;
        radius_Load2Bearing;
        
        abAdShaft_Su;
        abAdShaft_Ssu;
        abAdShaft_Sy;
        abAdShaft_Ssy;
        abAdShaft_Sn;
        abAdShaft_SnPrime;
        
        sigma_shaft;
        tau_shaft;
        sigmaea_shaft;
        sigmaem_shaft;
        
        n_abAdShaftShear;
        n_abAdShaftBending;
        n_abAdShaftFatigueBending;
        n_abAdShaftFatigueTorsion;
        
        C_L;
        C_G;
        C_S;
        C_T;
        C_R;
        K_f;
        K_fs;
    end
    
    methods
        function obj = ShaftAA(radius, length, density, rm2abd, rgs1b, rgs2b, rcb, rl2b, forceCounter,mat_Sy, mat_Su, mat_Ssu, Cs)
            obj.shaftAA_Radius = radius;
            obj.shaftAA_Length = length;
            obj.shaftAA_Density = density;
            obj.shaftAA_Weight = pi*obj.shaftAA_Radius^2*obj.shaftAA_Length*obj.shaftAA_Density*9.81;
            
            obj.moment_Inertia = (pi*(radius^2)*length*((2*radius))^2)/8; %keyword
            
            obj.force_Member2 = NaN;
            obj.force_Hip = NaN;
            obj.force_CounterWeight = forceCounter;
            obj.force_BushingY = NaN;
            obj.torque_BearingAbd = NaN;
            
            obj.radius_Member2Abd = rm2abd;
            obj.radius_GS1Bearing = rgs1b;
            obj.radius_GS2Bearing = rgs2b;
            obj.radius_CenterBearing = rcb;
            obj.radius_Load2Bearing = rl2b;
            
            obj.abAdShaft_Su = mat_Su; %Pa
            obj.abAdShaft_Ssu = mat_Ssu; %Pa
            obj.abAdShaft_Sy = mat_Sy; %Pa
            obj.abAdShaft_Ssy = 0.577*mat_Sy; %Max shear stress theory
            obj.abAdShaft_SnPrime = 0.5*mat_Su;
            obj.abAdShaft_Sn = NaN;
            
            obj.C_L = NaN; %will have bending or torsional loads
            if(obj.shaftAA_Radius < 0.005)
                obj.C_G = 1.0; %same for bending and torsional loads
            elseif((obj.shaftAA_Radius>=0.005) && (obj.shaftAA_Radius<0.025))
                obj.C_G = 0.9;
            else
                obj.C_G = 0.8;
            end
            obj.C_S = Cs; %machined surface finish, determine from fig 8.13 p323 in Juvinall and Marshek
            obj.C_T = 1; %room temp.
            obj.C_R = 0.753; %99% reliability
            obj.K_f = 1; %Profiled keyway with shaft over 200 Bhn in bending
            obj.K_fs = 1; %Profiled keyway with shaft over 200 Bhn in torsion
            obj.sigma_shaft = NaN;
            obj.tau_shaft = NaN;
            obj.sigmaea_shaft = NaN;
            obj.sigmaem_shaft = NaN;
            obj.n_abAdShaftShear = NaN;
            obj.n_abAdShaftBending = NaN;
            obj.n_abAdShaftFatigueBending = NaN;
            obj.n_abAdShaftFatigueTorsion = NaN;
        end
        
        function out = calculateForceMember2(obj,forceLoad,accel_y)
            obj.force_Member2 = (-1)*(obj.shaftAA_Weight/9.81*accel_y + forceLoad + obj.shaftAA_Weight);
            out = obj.force_Member2;
        end
        
        function out = calculateTorqueBearingABD(obj,forceGS1,forceGS2,forceLoad,weightMember1,weightMember2,aaccel,force_Hip)
            obj.torque_BearingAbd = (obj.moment_Inertia*aaccel)-((force_Hip - obj.force_CounterWeight-weightMember2)*obj.radius_Member2Abd)...
                +(forceGS1*obj.radius_GS1Bearing) + (forceGS2*obj.radius_GS2Bearing) + ((weightMember1)*obj.radius_CenterBearing)...
                -(forceLoad*obj.radius_Load2Bearing);
            out = obj.torque_BearingAbd;
        end
        
        %Failure Analysis%
        %4 failure cases: shear, bending, fatigue in bending, fatigue in
        %torsion
        function n_stress = ShaftAA_SF(obj, forceLoad,torque_BearingAbd)
            obj.tau_shaft = obj.K_fs*(4*abs(abs(forceLoad))/(3*pi*obj.shaftAA_Radius^2)+16*abs(torque_BearingAbd)/...
                (pi*(obj.shaftAA_Radius*2)^3));
            obj.n_abAdShaftShear = obj.abAdShaft_Ssy/obj.tau_shaft;
            %Max shear stress theory
           
            Mmax = (abs(abs(forceLoad))*(obj.shaftAA_Length/2));
            obj.sigma_shaft = 32*obj.K_f*Mmax/(pi*(obj.shaftAA_Radius*2)^3);
            obj.n_abAdShaftBending = obj.abAdShaft_Sy/obj.sigma_shaft;
            %Distortion energy theory
            n_stress=min([obj.n_abAdShaftShear obj.n_abAdShaftBending]);
           
        end
        
        function n_fatigue = ShaftAA_fatBendSF(obj, forceLoad_Max, force_BushingY_Max, torque_BearingAbdMAX)
            Mmax = abs((forceLoad_Max + force_BushingY_Max )* obj.shaftAA_Length);
            obj.sigmaea_shaft = (16/(pi*(obj.shaftAA_Radius*2)^3))*sqrt((4*(obj.K_f*Mmax)^2)+(3*(obj.K_fs*torque_BearingAbdMAX)^2));
            obj.sigmaem_shaft = obj.sigmaea_shaft; %the min force is 0 thus the magnitude of the alternating and mean force are the same
            obj.C_L = 1.0;
            obj.abAdShaft_Sn = obj.abAdShaft_SnPrime*obj.C_L*obj.C_G*obj.C_S*obj.C_T*obj.C_R; %Pa
            obj.n_abAdShaftFatigueBending = ((obj.sigmaea_shaft/obj.abAdShaft_Sn)+(obj.sigmaem_shaft/obj.abAdShaft_Su))^(-1);
            
            obj.C_L = 0.58;
            obj.abAdShaft_Sn = obj.abAdShaft_SnPrime*obj.C_L*obj.C_G*obj.C_S*obj.C_T*obj.C_R; %Pa
            obj.n_abAdShaftFatigueTorsion = ((obj.sigmaea_shaft/obj.abAdShaft_Sn)+(obj.sigmaem_shaft/obj.abAdShaft_Su))^(-1);
            %Modified Goodman
            
            n_fatigue=min([obj.n_abAdShaftFatigueBending obj.n_abAdShaftFatigueTorsion]);
        end
    end
end

