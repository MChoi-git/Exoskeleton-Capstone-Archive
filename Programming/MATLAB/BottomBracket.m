%Hip Bottom Bracket
%Input: Material Props, part dimensions
%Output: Safety factor
%Written by: Sharon Tam snd Matthew Choi
%Last update: October 23, 2019

classdef BottomBracket < handle
    
    properties
        force_Bottom_x;
        force_Bottom_y;
        t_bottomBracket;
        l_bracketGasSpr;
        l_bracketBottom;
        w_bottomBracket;
        bottom_Sy;
        bottom_Ssy;
        n_shearX;
        n_shearY;
        n_shearZ;
    end
    
    methods
        function obj = BottomBracket(mat_Sy, t_bottomBracket, l_bracketGasSpr, l_bracketBottom, w_bottomBracket)
            obj.force_Bottom_x = NaN;
            obj.force_Bottom_y = NaN;
            obj.t_bottomBracket = t_bottomBracket;
            obj.l_bracketGasSpr = l_bracketGasSpr;
            obj.l_bracketBottom = l_bracketBottom;
            obj.w_bottomBracket = w_bottomBracket;
            obj.bottom_Sy = mat_Sy;
            obj.bottom_Ssy = 0.577*mat_Sy;
            obj.n_shearX = NaN;
            obj.n_shearY = NaN;
            obj.n_shearZ = NaN;
        end
        
        function out = calculateForceBottom_x(obj,force_GasSpringBolt2_x)
            obj.force_Bottom_x = force_GasSpringBolt2_x;
            out = obj.force_Bottom_x;
        end
        
        function out = calculateForceBottom_y(obj,force_GasSpringBolt2_y)
            obj.force_Bottom_y = force_GasSpringBolt2_y;
            out = obj.force_Bottom_y;
        end
        
        function n_shearXY = bottomBracket_XYshearSF(obj,force_GasSpringBolt2_x, force_GasSpringBolt2_y)
            %tau x is transverse shear
            tauX = abs(1.5*force_GasSpringBolt2_x)/(obj.t_bottomBracket*obj.w_bottomBracket);
            obj.n_shearX = obj.bottom_Ssy/tauX;
            %tau y is direct shear
            tauY = abs(force_GasSpringBolt2_y)/(obj.t_bottomBracket*obj.w_bottomBracket);
            obj.n_shearY = obj.bottom_Ssy/tauY;
            n_shearXY = min([obj.n_shearX obj.n_shearY]);
        end
    end
end