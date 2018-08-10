function dt = mcTimeStep(rates)
%MCTIMESTEP Monte carlo time step.
%
%MCTIMESTEP(rates) Takes a vector or rates and randomly picks a time step, 
%dt, based on those rates. Useful for Monte Carlo simulations.
if ~isvector(rates)
    error('rates must be a vector.')
end
dt = -log(rand) / sum(rates);
%dt = random('exp', 1 / sum(rates));
end

