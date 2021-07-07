classdef TopBracket < handle
    %Top bracket, written by Matt. 
    %UPDATE
    properties
        force_GasSpringBracket1_x;
        force_GasSpringBracket1_y;
        
        TopBracket_T; %Thickness of the Sheet metal
        TopBracket_L_BGS; %inside length by the gas spring hole
        TopBracket_L_BB; %inside length by the bolt hole
        TopBracket_W; %Defined in the z direction of the fbd
        YS;
        n_DS;
        n_trans;
    end
    
    methods
        function obj = TopBracket(YS,TopBracket_T,TopBracket_L_BGS,TopBracket_L_BB,TopBracket_W)
            obj.force_GasSpringBracket1_x = NaN;
            obj.force_GasSpringBracket1_y = NaN;
            
            obj.TopBracket_T = TopBracket_T;
            obj.TopBracket_L_BGS = TopBracket_L_BGS;
            obj.TopBracket_L_BB = TopBracket_L_BB;
            obj.TopBracket_W = TopBracket_W;
            obj.YS = YS;
            obj.n_DS = NaN;
            obj.n_trans = NaN;
        end
        function out = calculateForceGasSpringBracket1_x(obj,forceGS1X)
            obj.force_GasSpringBracket1_x = forceGS1X;
            out = obj.force_GasSpringBracket1_x;
        end
        function out = calculateForceGasSpringBracket1_y(obj,forceGS1Y)
            obj.force_GasSpringBracket1_y = forceGS1Y;
            out = obj.force_GasSpringBracket1_y;
        end
        
        %Determine Minimum Safety Factor
        %Parameters: TopBracket Object
        %Return: minimum safety factor (n_stress)
        function n_stress = getn_stress(obj,force_GasSpringBracket1_x,force_GasSpringBracket1_y)
           tau = force_GasSpringBracket1_y/(obj.TopBracket_T*obj.TopBracket_W);
           Ssy = 0.577*obj.YS;
           
           obj.n_DS = Ssy/tau;
           
           tau_trans = 1.5*force_GasSpringBracket1_x/(((0.5*obj.TopBracket_L_BGS)+obj.TopBracket_T)*obj.TopBracket_W);
           obj.n_trans = Ssy/tau_trans;
           
           n_stress = min([obj.n_DS obj.n_trans]);
        end
        
    end
end

