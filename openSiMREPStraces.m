function traces = openSiMREPStraces(filename)
% Args:
%   filename(string or char vector): path to file containing traces (*traces.dat, 'mat' format)

    traces = load(FileName,'-mat');
    traces = traces.traces;
end