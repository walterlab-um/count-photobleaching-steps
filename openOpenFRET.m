function traces = openOpenFRET(filename, donor_crosstalk)
%Args:
    % filename(string or char) = path and filename of .traces file containing two-channel single-molecule data in binary (ieee-le) format
    % donor_crosstalk(double) = fraction of donor-channel signal that appears in acceptor channel (typical value = 0.09)

    % Read dataset from OpenFRET JSON file
    if strcmp(filename(end-2:end),'zip')
        unzip(filename);
        dataset = openfret.read(filename(1:end-4));
        delete(filename(1:end-4));
    else
        dataset = openfret.read(filename);
    end

    Ntraces = length(dataset.traces);

    % Parse intensity values from dataset into separate donor and acceptor matrices (row = trace, col = frame)
    for n=1:(Ntraces)
        donor(n,:)=dataset.traces(n).channels(1).data;
        acceptor(n,:)=dataset.traces(n).channels(2).data;
    end

    % Correct acceptor channel for donor crosstalk
    acceptor = acceptor - donor*donor_crosstalk;

    % Store intensities and peak positions in output struct
    traces.donor = donor;
    traces.acceptor = acceptor;
end