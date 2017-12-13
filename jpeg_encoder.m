%Simple jpeg encoder for grayscale images
function out = jpeg_encoder(img)
    if ~ismatrix(img)% || ~isa(img, 'uint8')
        error('Input error, should be uint8 image');
    end
    
    block_size = 8;
    %transfrom normalization array
    Z = [16 11 10 16 24 40 51 61;
        12 12 14 19 26 58 60 55;   
        14 13 16 24 40 57 69 56; 
        14 17 22 29 51 87 80 62;
        18 22 37 56 68 109 103 77;
        24 35 55 64 81 104 113 92;
        49 64 78 87 103 121 120 101;
        72 92 95 98 112 100 103 99];

    %zig-zag reordering pattern
    zig_zag = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33  ...
     41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 ...
     43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 ...
     45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 ...
     62 63 56 64];
 
    %zag = [64:-1:1];
 
    %level shifting the image, we know the 2^8 - number of grey levels
    img = img - 128;
    %checking whether we can divide image in 8 by 8 blocks, othewise
    %resizing is made
    [rows, cols] = size(img);
    if ((mod(rows, block_size) ~= 0) || (mod(rows, block_size) ~= 0))
        rows = floor(rows/block_size)*8;
        cols = floor(cols/block_size)*8;
        img = imresize(img,[rows, cols]);
    end
    %transformation matrix for discrete cosine transform
    H = dctmtx(block_size);
    %application of dct and its normalization
    ndct_func = @(block) round((H * block.data * H')./Z);
    ndct_img = blockproc(img, [block_size, block_size], ndct_func);
    
    %reodering according to zig-zag pattern
    ndct_array = im2col(ndct_img, [block_size, block_size], 'distinct');
    ndct_array = ndct_array(zig_zag, :);
    
    end_of_block = max(img(:)) + 1;
    %number_of_blocks = (rows * cols)/(block_size * block_size);
    number_of_blocks = size(ndct_array, 2);
    
    stream_data = zeros(numel(ndct_array) + size(ndct_array, 2), 1);
    count = 0;
    
    for i = 1:number_of_blocks
        nonzero_index = find(ndct_array(:, i), 1, 'last');
        %check if there are no non-zero values
        if isempty(nonzero_index)
            nonzero_index = 0; 
        end 
        p = count + 1;
        q = p + nonzero_index;
        %truncate zeros after last non-zero element and append end of block
        %symbol
        stream_data(p:q)  = [ndct_array(1:nonzero_index, i); end_of_block];
        count = count + nonzero_index + 1;          % and add to output vector
    end
    stream_data((count + 1):end) = [];            % delete unused portion of streams_together
    
    %Huffman ecoding of stream data
    symbols = unique(stream_data);
    probs = histc(stream_data,symbols);
    probs = probs/sum(probs);
    
    huffman_dict = huffmandict(symbols, probs);
    huffman_stream_data = huffmanenco(stream_data, huffman_dict);
    
    out = struct;
    out.size = uint16([rows, cols]);
    out.numblocks = uint16(number_of_blocks);
    %with used transform normalization table we have 50% quality
    out.quality = uint16(50);
    out.data = huffman_stream_data;
end