%% Options
options.snr_thresh = 3; % Minimum SNR for a bleaching event to be counted
options.mol_thresh = 1000; % Minimum molecule intensity to analyze photobleaching steps
options.report_individual_results = true; % true = plot each trace's results individually
options.channel = 'acceptor'; % (For 2-channel traces files): which channel to analyze for photobleaching steps. values: 'donor' or 'acceptor'
options.donor_crosstalk = 0.09; % (For 2-channel traces files): crosstalk of donor into acceptor channel, as fraction of donor-channel signal
options.relative_stepsize_cutoff = 3; % Candidate photobleaching steps will be ignored if they are smaller than the largest bleaching step by at least this factor

%% Get Input File Names
fprintf(1,'Please select all the movie files for counting photobleaching steps\n')
[filename, path] = uigetfile('*traces.dat;*traces.mat;*.traces','Please select your traces files.','Multiselect','on');
% This is just in case the user selects only one file (converts array ->
% cell array), because the rest of the code expects a cell array.
if ~iscell(filename)
    filename = {filename};
end
if path == 0
    disp('No file selected; aborting.');
    return
end
cd(path);

%% Cycle through all files and determine number of photobleaching steps for each trace
psteps = zeros(0,1); % Initialize matrix of photobleaching steps
nfiles = length(filename);
for n=1:nfiles
    filepath = strcat(path,filename{n});
    if strcmp(filepath(end-3:end),'.dat') || strcmp(filepath(end-3:end),'.mat')
        traces = openSiMREPStraces(filepath);
    elseif strcmp(filepath(end-6:end),'.traces')
        traces2ch = openTraces(filepath,options.donor_crosstalk);
        if strcmpi(options.channel,'donor')
            traces = traces2ch.donor;
        elseif strcmpi(options.channel,'acceptor')
            traces = traces2ch.acceptor;
        else
            error("channel must be 'donor' or 'acceptor");
        end
    end

    psteps = vertcat(psteps,countSteps(traces,options));
end

%% Show cumulative results
figure(1)
hist(psteps,0:1:7);
ylabel('Counts');
xlabel('Photobleaching Steps');
