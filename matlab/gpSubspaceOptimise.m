function model = gpSubspaceOptimise(model,varargin)

% GPSUBSPACEOPTIMISE
%
% COPYRIGHT : Carl Henrik Ek, 2008
  
% SHEFFIELDML

model = gpOptimise(model,varargin{:});

return;