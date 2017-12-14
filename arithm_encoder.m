function out = arithm_encoder(symbols, probs, sequence)
    % Function realizes arithmetic encoding algorithm, symbols is
    % cell array of symbols used for encoding of provided sequence, probs
    % is one-dimensional array of numbers each of which representing 
    % probability of occurence of corresponding symbol from symbols cell
    % array, sequence is a sequnce to be encoded. Returns binary 
    % represetation as 2^(-n) of real number n, such that 0<=n<=1
    %
    prob_map = containers.Map(symbols, probs);
    
    interval_low = zeros(1, length(probs));
    
    for i = 1:length(probs)
        if (i == 1)
            interval_low(i) = 0;
        else
            interval_low(i) = interval_low(i-1) + probs(i - 1);
        end    
    end
    
    interval_low_map = containers.Map(symbols, interval_low);
    %encoding
    new_high = 0;
    new_low = 0;
    
    for i = 1:length(sequence)
        symbol = sequence{i};
        
        if (i == 1)
            old_low = 0;
            old_high = 1;
        else
            old_low = new_low;
            old_high = new_high;
        end
        
        range = vpa(old_high - old_low);
        new_high = vpa(old_low + range*(prob_map(symbol) + interval_low_map(symbol)));
        new_low = vpa(old_low + range*interval_low_map(symbol));
    end
    
    bin_seq_dec = 0;
    bin_seq = '';
    power = 0;
    %looking for sequence of power 2^-n, that will be between this boundaries 
    while ~((bin_seq_dec < new_high) && (bin_seq_dec > new_low))
        if (vpa(bin_seq_dec + 2^power) < new_high)
            bin_seq = [bin_seq, '1'];
        else
            bin_seq = [bin_seq, '0'];
        end
        bin_seq_dec = vpa(bin2dec(bin_seq)/2^(length(bin_seq)-1));
        power = power -1;
    end
    
    out = bin_seq;
end