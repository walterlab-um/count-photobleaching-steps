% Extract single channel from two-channel traces data
function traces = extractChannel(traces2ch,channel)
    if strcmpi(channel,'donor')
        traces = traces2ch.donor;
    elseif strcmpi(channel,'acceptor')
        traces = traces2ch.acceptor;
    else
        error("channel must be 'donor' or 'acceptor");
    end
end