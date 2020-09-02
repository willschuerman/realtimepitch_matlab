function [f0diff] = modProbs(f0diff, tone)

switch tone
    case 1
        f0diff = abs(f0diff)*2; % no difference between increases and decreases, penalize jumps
    case 2
        f0diff(f0diff<0) = f0diff(f0diff<0)*2; % penalize decreases
        f0diff = abs(f0diff); 
    case 3
        f0diff = abs(f0diff)/5; % don't penalize jumps
        f0diff = abs(f0diff);
    case 4
        f0diff(f0diff>0) = f0diff(f0diff>0)*3; % penalize increases
        f0diff = abs(f0diff);
end