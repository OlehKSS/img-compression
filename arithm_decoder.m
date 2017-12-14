function out = arithm_decoder(symbols, probs, bin_sequence, number_of_chars)
    % Function realizes arithmetic decoding algorithm, symbols is
    % cell array of symbols used for encoding of provided sequence, probs
    % is one-dimensional array of numbers each of which representing 
    % probability of occurence of corresponding symbol from symbols cell
    % array, bin_sequence is a binary representation returned by 
    % arithm_encoder function, number_of_chars is number of characters that
    % we should decode. Returns char array of decoded symbols
    bin_seq_dec = vpa(bin2dec(bin_sequence)/2^(length(bin_sequence)-1)); 
    sequence = blanks(number_of_chars);
    
    interval = zeros(1, length(probs) + 1);
    lower_boundary = 0;
    range = 1;
    
    for s = 1:number_of_chars
        for i = 1:length(probs)
            if (i == 1)
                interval(i) = lower_boundary;
            else
                interval(i) = vpa(interval(i-1) + probs(i - 1) * range);
            end    
        end
        interval(end) = vpa(lower_boundary + range);

        %interval_low_map = containers.Map(interval_low, symbols);

        for i = 2:length(interval)
            if ((bin_seq_dec > interval(i - 1)) && (bin_seq_dec < interval(i)))
                %we decoded new interval for a symbol, send it to output
                sequence(s)= symbols{i-1};
                %saving new range and its start
                lower_boundary = interval(i - 1);
                range = vpa(interval(i) - interval(i - 1));
                break;
            end
        end
    end
       
    out = sequence;
end