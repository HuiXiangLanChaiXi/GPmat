function kern = rbfwhiteKernExpandParam(kern, params)

% RBFWHITEKERNEXPANDPARAM Create kernel structure from RBF-WHITE kernel's
% parameters.
% FORMAT
% DESC returns a RBF-WHITE kernel structure filled with the parameters in
% the given vector. This is used as a helper function to enable parameters
% to be optimised in, for example, the NETLAB optimisation functions.
% ARG kern : the kernel structure in which the parameters are to be
% placed.
% ARG param : vector of parameters which are to be placed in the
% kernel structure.
% RETURN kern : kernel structure with the given parameters in the
% relevant locations.
%
% SEEALSO : rbfwhiteKernParamInit, rbfwhiteKernExtractParam, kernExpandParam
%
% COPYRIGHT : David Luengo, 2009

% SHEFFIELDML


kern.inverseWidth = params(1);
kern.variance = params(2);
