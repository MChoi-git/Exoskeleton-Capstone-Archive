% CBoot Written By: Megan
% Date last modified: 2019-10-18
% Note: Fix safety factor 


classdef ABolt < handle
    properties 
        %Material Data%
        YS;
        ABolt_D;

        %Pure Shear Stress%
        n_PS;
        
        %Rupture%
        n_R;
        
        %Bearing on Bolt%
        n_BB;
        
        %Bearing on Member%
        n_BM;
    end
    
    methods
        function obj = ABolt(YS, ABolt_D)%Initialize this guy 
            obj.YS = YS;
            obj.ABolt_D = ABolt_D;
            obj.n_PS = NaN;
            obj.n_R = NaN;
            obj.n_BB = NaN;
            obj.n_BM = NaN;
        end
        
        function n_bolt = getbolt_n(obj, Ubarobj, shank_W_nominal, shank_T_nominal, shank_L_nominal, shank_Sy) %Calculate forces in Y to find acceleration in the Y
           %Pure Shear%
           A = (pi*(obj.ABolt_D^2))/4;
           tau1 = abs((Ubarobj.F_LS_y)/A);
           tau2 = abs((Ubarobj.F_LS_x)/A);
           Ssy = 0.577*(obj.YS);
           
           holder = [tau1 tau2];
           tau = max(holder);
           obj.n_PS = Ssy/tau;
           
           %Rupture%
           A_Ubar1 = Ubarobj.Ubar_W_nominal*Ubarobj.Ubar_T_nominal;
           A_Ubar2 = Ubarobj.Ubar_L_nominal*Ubarobj.Ubar_T_nominal;
           
           
           A_LShank1 = shank_W_nominal*shank_T_nominal;
           A_LShank2 = shank_L_nominal*shank_T_nominal;
           
           holder1 = [A_Ubar1 A_LShank1];
           holder2 = [A_Ubar2 A_LShank2];
           
           A1 = min(holder1);
           A2 = min(holder2);
           
           sigma1 = abs(Ubarobj.F_LS_x)/A1;
           sigma2 = abs(Ubarobj.F_LS_y)/A2;
           
           holder = [sigma1 sigma2];
           sigma = max(holder);
           
           obj.n_R = obj.YS/sigma;
           
           %Bearing on Bolt and Member%
           holder = [abs(Ubarobj.Ubar_T_nominal) abs(shank_T_nominal)];
           T = min(holder);
           if T == Ubarobj.Ubar_T_nominal
               YS1 = Ubarobj.Ubar_YS;
           else 
               YS1 = shank_Sy;
           end
           
           sigma1 = abs(Ubarobj.F_LS_x/(T*obj.ABolt_D));
           sigma2 = abs(Ubarobj.F_LS_y/(T*obj.ABolt_D));
           holder = [sigma1 sigma2];
           sigma = max(holder);
           obj.n_BB = obj.YS/sigma;
           obj.n_BM = YS1/sigma;
           
           holder = [obj.n_PS, obj.n_R, obj.n_BB, obj.n_BM];
           n_bolt = min(holder);
        end
    end
end