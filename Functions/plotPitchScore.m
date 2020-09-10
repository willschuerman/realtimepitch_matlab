function [pitchScore] = plotPitchScore(f0s,f0cents,modelF0s,barwidth,useCents)

    pitchScore = getPitchScore(f0s,f0cents,modelF0s,barwidth,useCents);
    if pitchScore == 1
        scoreLabel = 'PERFECT!';
    elseif pitchScore >= 0.9
        scoreLabel = 'GREAT!';
    elseif pitchScore >= 0.75
        scoreLabel = 'Good job!';
    elseif pitchScore >= 0.5
        scoreLabel = 'Pretty good';
    else
        scoreLabel = 'Keep practicing';
    end
    title({sprintf('Score = %g',round(pitchScore,2)),scoreLabel},'FontSize',30)
    drawnow()
end