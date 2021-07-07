classdef GasSpring < handle
    %Gas springs, written by Matt
    
    properties
        gasSpring_Length;
        gasSpring_Diameter;
        gasSpring_Weight;
        
        force_GasSpringBolt2_y;
        force_GasSpringBolt2_x;
        
    end
    
    methods
        function obj = GasSpring(length,diameter)
            
            obj.gasSpring_Length = length;
            obj.gasSpring_Diameter = diameter;
            obj.gasSpring_Weight = 9.81*(pi*diameter/4)*length;
            
            obj.force_GasSpringBolt2_y = NaN;
            obj.force_GasSpringBolt2_x = NaN;
        end
        
        function out = calculateForceGasSpringBolt2_y(obj,forceGasSpringBolt1_y)
            obj.force_GasSpringBolt2_y = forceGasSpringBolt1_y;
            out = obj.force_GasSpringBolt2_y;
        end
        function out = calculateForceGasSpringBolt2_x(obj,forceGasSpringBolt1_x)
            obj.force_GasSpringBolt2_x = -forceGasSpringBolt1_x;
            out = obj.force_GasSpringBolt2_x;
        end
    end
end

