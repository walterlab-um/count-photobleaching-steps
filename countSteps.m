function [psteps] = countSteps(traces,thresh,mol_thresh,max_steps,report_individual_results)
% Args:
%   traces(2D matrix of double) = traces to be analyzed for photobleaching steps (rows = traces, columns = frames)
%   thresh(double) = minimum intensity change to count as photobleaching step
%   report_individual_results(logical) = whether to display plots and results for individual traces

psteps = zeros(size(traces,1),1);
for m = 1:size(traces,1)
    trace = traces(m,:);
    if max(trace) < mol_thresh
        psteps(m,1) = NaN;

    else
    % scale = max(trace);
    % idealized = cell2mat(vbFRET_idealize({trace/scale},max_steps))*scale;
    % dtrace = idealized(2:end)-idealized(1:end-1);
    idealized = smoothdata(trace,"gaussian",5);
    dtrace = idealized(5:end)-idealized(1:end-4);
    psteps(m,1) = 0;
    for k = 2:length(dtrace)
        if dtrace(k) < -thresh
            if dtrace(k-1) >= -thresh
                psteps(m,1) = psteps(m,1)+1;
            end
        elseif dtrace(k) > thresh
            if  psteps(m,1) >= 0
                psteps(m,1) = psteps(m,1) - 1;
            end
        end
    end
    if report_individual_results
        figure(1)
        plot(trace,'k-');
        hold on
        plot(idealized,'r');
        hold off
        title(sprintf('Trace number: %d    Photobleaching steps: %d',m,psteps(m,1)));
        pause;
    end
    end
end

psteps = removeNaNrows(psteps);

end