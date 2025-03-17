t_thresh = 500; % Minimum intensity change to count as a photobleaching step
mol_thresh = 1000; % Minimum molecule intensity to analyze photobleaching steps
report_individual_results = true; % true = plot each trace's results individually
channel = 'acceptor'; % (For 2-channel traces files): which channel to analyze for photobleaching steps. values: 'donor' or 'acceptor'
donor_crosstalk = 0.09; % (For 2-channel traces files): crosstalk of donor into acceptor channel, as fraction of donor-channel signal
max_steps = 6; % Maximum expected photobleaching steps to try fitting

%% Get Input File Names
fprintf(1,'Please select all the movie files for counting photobleaching steps\n')
[filename, path] = uigetfile('*traces.dat;*traces.mat;*.traces','Please select your traces files.','Multiselect','on');
% This is just in case the user selects only one file (converts array ->
% cell array), because the rest of the code expects a cell array.
if ~iscell(filename)
    G = cell(1);
    G{1} = filename;
    filename = G;
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
        traces2ch = openTraces(filepath,donor_crosstalk);
        if strcmpi(channel,'donor')
            traces = traces2ch.donor;
        elseif strcmpi(channel,'acceptor')
            traces = traces2ch.acceptor;
        else
            error("channel must be 'donor' or 'acceptor");
        end
    end

    psteps = vertcat(psteps,countSteps(traces,t_thresh,mol_thresh,report_individual_results,max_steps));
end

%% Show cumulative results
figure(1)
hist(psteps,0:1:7);
ylabel('Counts');
xlabel('Photobleaching Steps');
