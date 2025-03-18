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
        idealized = smoothdata(smoothdata(trace,"movmedian",9),"movmedian",9);
        thresh = snr_thresh*std(idealized-trace); % Threshold based on snr_thresh and noise level of current trace
        dtrace = horzcat(zeros(1,4),idealized(5:end)-idealized(1:end-4),zeros(1,4));
        psteps(m,1) = 0;
        for k = 2:length(dtrace)
            if ~fullyBleached
                if dtrace(k) < -thresh
                    if dtrace(k-1) >= -thresh
                        psteps(m,1) = psteps(m,1)+1;
                        % bleachFrame(k) = 1*max(idealized);
                        if k < length(idealized-20)
                            bleachIntensity = cat(1,bleachIntensity,idealized(k-1)-median(idealized(k+1:k+20)));
                        else
                            bleachIntensity = cat(1,bleachIntensity,idealized(k-1)-idealized(k+1));
                        end
                        bleachFrame = cat(1,bleachFrame,k);
                        if k < length(dtrace)-20
                            if abs(mean(idealized(k+10:k+20)) - mean(idealized(idealized<(min(idealized)+thresh)))) < thresh
                                fullyBleached = true;
                            end
                        end
                    end
                elseif dtrace(k) > thresh
                    if  psteps(m,1) > 0
                        psteps(m,1) = psteps(m,1) - 1;
                        bleachIntensity = cat(1,bleachIntensity,idealized(k-1)-idealized(k+1));
                        bleachFrame = cat(1,bleachFrame,k);
                    end
                end
            end
        end
        % Remove photobleaching steps followed by upward steps
        ind = zeros(0,1);
        for n = 2:length(bleachIntensity)
            if bleachIntensity(n)<0
                ind = cat(1,ind,n-1,n);
            end
        end
        bleachIntensity(ind)=[];
        bleachFrame(ind)=[];
        % Reassess photobleaching steps by counting only those with
        % intensity changes at least 50% of largest bleaching step
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