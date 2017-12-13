%% Test 1.1
alph = {'A', 'C', 'T', 'G'};
probs = [0.5, 0.3, 0.15, 0.05];
seq = 'ACTAGC';
%splits sequence into cell array of separate characters
seq_cellarr = cellstr(seq')';
disp('--------------------Test 1------------------------');
encoded_seq = arithm_encoding(alph, probs, seq_cellarr);
disp(strcat('Output binary sequence: ', encoded_seq));
decoded_seq = arithm_decoder(alph, probs, encoded_seq, length(seq));
disp(strcat('Decoded sequence: ', decoded_seq));
%% Test 1.2
seq2 = 'BE_A_BEE';
alph2 = {'A', 'B', 'E', '_'};
probs2 = [1, 2, 3, 2]./length(seq2);
%splits sequence into cell array of separate characters
seq_cellarr2 = cellstr(seq2')';
disp('--------------------Test 2------------------------');
encoded_seq2 = arithm_encoding(alph2, probs2, seq_cellarr2);
disp(strcat('Output binary sequence: ', encoded_seq2));
decoded_seq2 = arithm_decoder(alph2, probs2, encoded_seq2, length(seq2));
disp(strcat('Decoded sequence: ', decoded_seq2));
%% Test of jpeg encoder
%simple test
disp('-----------------Test of jpeg encoder-------------------');
pxs = [139 144 149 153 155 155 155 155;
    144 151 153 156 159 156 156 156;
    150 155 160 163 158 156 156 156;
    159 161 162 160 160 159 159 159;
    159 160 161 162 162 155 155 155;
    161 161 161 161 160 157 157 157;
    162 162 161 163 162 157 157 157;
    162 162 161 161 163 158 158 158];
    
jpeg_t1 = jpeg_encoder(pxs);
str_data = num2str(jpeg_t1.data)';
disp(strcat('Output binary sequence: ', str_data));

test_img = imread('test.bmp');
jpeg_t2 = jpeg_encoder(double(test_img));

%Writes jpeg image to a file 'test.jpg'
jpeg_soi = {'FF';'D8'};
jpeg_sos = {'FF'; 'DA'};
jpeg_appo_marker = {'FF'; 'E0'; '00'; '10'; '4A'; '46'; '49'; '46'; '00'; '01'; '01'; '00'; '02'; '00'; '01'; '58'; '00'; '00'};
jpeg_appo_compr = {'FF'; 'E0'; '00'; '08'; '4A'; '46'; '49'; '46'; '00'; '10'};
jpeg_eoi = {'FF'; 'D9'};

fid = fopen('test.jpg', 'w');
fwrite(fid, hex2dec(jpeg_soi), 'uint8');
fwrite(fid, hex2dec(jpeg_appo_marker), 'uint8');
fwrite(fid, hex2dec(jpeg_appo_compr), 'uint8');
fwrite(fid, hex2dec(jpeg_sos), 'uint8');
fwrite(fid, jpeg_t2.data, 'ubit1');
fwrite(fid, hex2dec(jpeg_eoi), 'uint8');
fclose(fid);




