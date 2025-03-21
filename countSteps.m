function [psteps] = countSteps(traces,options)
% Args:
%   traces(2D matrix of double) = traces to be analyzed for photobleaching steps (rows = traces, columns = frames)
%   t_thresh(double) = minimum intensity change to count as photobleaching step
%   mol_thresh(double) = smallest maximum intensity to evaluate a trace
%   report_individual_results(logical) = whether to display plots and results for individual traces

%% Unpack options
snr_thresh = options.snr_thresh;
mol_thresh = options.mol_thresh;
report_individual_results = options.report_individual_results;
relative_stepsize_cutoff = options.relative_stepsize_cutoff;

%% Calculate number of photobleaching steps
psteps = zeros(size(traces,1),1);
for m = 1:size(traces,1)
    trace = traces(m,:);
    fullyBleached = false;
    bleachState = trace*0;
    bleachFrame = zeros(0,1);
    bleachIntensity = zeros(0,1);
    if max(trace) < mol_thresh
        psteps(m,1) = NaN;
    else
        [idealized,dtrace,thresh] = determine_transition_points(trace,snr_thresh);
        psteps(m,1) = 0;
        for k = 2:length(dtrace)-5
            if ~fullyBleached
                if dtrace(k) < -thresh
                    if dtrace(k-1) >= -thresh
                        psteps(m,1) = psteps(m,1)+1;
                        bleachIntensity = cat(1,bleachIntensity,idealized(k-1)-median(idealized(k+1:k+5)));
                        bleachFrame = cat(1,bleachFrame,k);
                    end
                elseif dtrace(k) > thresh
                    if  psteps(m,1) > 0
                        psteps(m,1) = psteps(m,1) - 1;
                        bleachIntensity = cat(1,bleachIntensity,idealized(k-1)-idealized(k+1));
                        bleachFrame = cat(1,bleachFrame,k);
                    end
                end
            end
            if abs(idealized(k-1) - min(idealized)) < thresh % if ending intensity within thresh of baseline
                fullyBleached = true;
            end
        end
        % Remove photobleaching steps preceded by upward steps
        ind = zeros(0,1);
        for n = 2:length(bleachIntensity)
            if bleachIntensity(n-1)<0
                ind = cat(1,ind,n-1,n);
            end
        end
        bleachIntensity(ind)=[];
        bleachFrame(ind)=[];
        % Reassess photobleaching steps by counting only those with intensity changes within a factor of (relative_stepsize_cutoff) of the largest bleaching step
        if length(bleachIntensity)>0
            ind = abs(bleachIntensity) < max(bleachIntensity)/relative_stepsize_cutoff;
            bleachIntensity(ind) = [];
            bleachFrame(ind) = [];
        end
        if ~isempty(bleachFrame)
            bleachState(bleachFrame) = max(idealized);
            psteps(m,1) = sum(bleachIntensity>0) - sum(bleachIntensity<0);
            endframe = min([max(bleachFrame)+200,length(trace)]); % final frame to display in plotting
        else
            endframe = length(trace);
        end
        if report_individual_results
            figure(1)
            plot(trace(1:endframe),'k-');
            hold on
            plot(idealized(1:endframe),'r');
            plot(bleachState(1:endframe),'b');
            hold off
            title(sprintf('Trace number: %d    Photobleaching steps: %d',m,psteps(m,1)));
            pause;
        end
    end
end

psteps = removeNaNrows(psteps);

end

function [idealized,dtrace,thresh] = determine_transition_points(trace,snr_thresh)
    smoothed = smoothdata(smoothdata(trace,"movmedian",9),"movmedian",9);
    thresh = snr_thresh*std(smoothed-trace); % Threshold based on snr_thresh and noise level of current trace
    dtrace = difftrace(smoothed,4);
    pts = find(abs(dtrace) > thresh);
    ind = cat(2,1,pts(2:end)-pts(1:end-1)>1);
    if ~isempty(pts)
        pts = horzcat(pts(find(ind))); % Eliminate transition points that immediately follow other transitions
    end
    pts = horzcat(1,pts,length(trace));
    idealized = trace;
    for n = 1:length(pts)-1 % average signal for each segment
        idealized(pts(n):pts(n+1)-1) = mean(trace(pts(n):pts(n+1)-1));
    end
    % Recalculate more accurate thresh based on idealization
    thresh = snr_thresh*std(idealized-trace); 
    dtrace = horzcat(zeros(1,1),idealized(2:end)-idealized(1:end-1));
    % figure(1); plot(trace,'k'); hold on; plot(idealized,'r'), plot(dtrace,'b'); 
    % hold off;
end

function dtrace = difftrace(trace,dframe)
% Args:
    % trace = intensity trace (1 x n vector) to create differential trace (dtrace) from
    % dframe = subtraction window
    dtrace = zeros(size(trace));
    for n = 1:floor(dframe/2)
        dtrace(n) = trace(n+floor(dframe/2))-trace(1);
    end
    for n = length(trace)-ceil(dframe/2):length(trace)
        dtrace(n) = trace(end)-trace(n);
    end
    dtrace(dframe/2+1:length(trace)-dframe/2) = trace(dframe+1:end)-trace(1:end-dframe);
end