classdef GasSpringBolts < handle
    %Gas spring bolts, written by Matt
    properties
        force_GasSpringBolt1_x;
        force_GasSpringBolt1_y;
        YS;
        n_PS;
        n_R;
        n_BB;
        n_BM;
    end
    
    methods
        function obj = GasSpringBolts(YS)
            obj.force_GasSpringBolt1_x = NaN;
            obj.force_GasSpringBolt1_y = NaN;
            obj.YS = YS;
            obj.n_PS = NaN;
            obj.n_R = NaN;
            obj.n_BB = NaN;
            obj.n_BM = NaN;
        end
        
        function out = calculateForceGasSpringBolt1_x(obj,forceBracket_x)
            obj.force_GasSpringBolt1_x  = forceBracket_x;
            out = obj.force_GasSpringBolt1_x;
        end
        
        function out = calculateForceGasSpringBolt1_y(obj,forceBracket_y)
            obj.force_GasSpringBolt1_y = forceBracket_y;
            out = obj.force_GasSpringBolt1_y;
        end
        
        %Calculate minimum bolt safety factor
        %Parameters: Bolt Object, GasSpringobj, TopBracketobj, SpringBolt_D
        %Return: minimum safety factor
        function n_bolt = getbolt_n(obj, TopBracket_W, TopBracket_T,TopBracket_L_BGS,GasSpring_T_Eyelet,GasSpring_D_Eyelet...
                , SpringBolt_D,topBracketYS,gasSpringYS,force_GasSpringBolt1_x,force_GasSpringBolt1_y) %Calculate forces in Y to find acceleration in the Y
           %Pure Shear%
           A = (pi*(SpringBolt_D^2))/4;
           tau1 = (force_GasSpringBolt1_y)/A;
           tau2 = (force_GasSpringBolt1_x)/A;
           Ssy = 0.577*(obj.YS);
         
           holder = [tau1 tau2];
           tau = max(holder);
           obj.n_PS = Ssy/tau;
           
           %Rupture%
           A_TopBracket1 = TopBracket_W*TopBracket_T;
           A_TopBracket2 = TopBracket_L_BGS*TopBracket_T;
           
           A_GasSpring_Eyelet = GasSpring_T_Eyelet*GasSpring_D_Eyelet;
           
           holder1 = [A_TopBracket1 A_GasSpring_Eyelet];
           holder2 = [A_TopBracket2 A_GasSpring_Eyelet];
           
           A1 = min(holder1);
           A2 = min(holder2);
           
           sigma1 = force_GasSpringBolt1_y/A1;
           sigma2 = force_GasSpringBolt1_x/A2;
           
           holder = [sigma1 sigma2];
           sigma = max(holder);
           
           obj.n_R = obj.YS/sigma;
           
           %Bearing on Bolt and Member%
           holder = [TopBracket_T GasSpring_T_Eyelet];
           T = min(holder);
           if T == TopBracket_T
               YS1 = topBracketYS;
           else 
               YS1 = gasSpringYS;
           end
           
           sigma1 = force_GasSpringBolt1_x/(T*SpringBolt_D);
           sigma2 = force_GasSpringBolt1_y/(T*SpringBolt_D);
           holder = [sigma1 sigma2];
           sigma = max(holder);
           obj.n_BB = obj.YS/sigma;
           obj.n_BM = YS1/sigma;
           
           holder = [obj.n_PS, obj.n_R, obj.n_BB, obj.n_BM];
           n_bolt = min(holder);
        end
    end
end

