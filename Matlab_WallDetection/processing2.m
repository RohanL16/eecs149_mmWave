%{
mmWave project
EECS 149
Data processing for RAW ADC data.
RAW ADC data are IF signals. Mix of Tx chirp and Rx chirp. 
IF = sin(WTx - Wrx) (theta)
%}

clear all;

%Different samples
file = readtable('C:\\Users\\Alex\\Desktop\\adc_data_3.dat'); %data for single wall 90°
file2 = readtable('C:\\Users\\Alex\\Desktop\\adc_data_4.dat'); %data for person in front of a wall
file3 = readtable('C:\\Users\\Alex\\Desktop\\adc_data_5.dat'); %data for wall corner

%Pre allocate cells for ADC data
listcomplex1 = cell(225, 1);
listcomplex2 = cell(225, 1);
listcomplex3 = cell(225, 1);
listcomplex4 = cell(225, 1);
listreal = cell(225, 1);
listreal2 = cell(225, 1);
listreal3 = cell(225, 1);
listreal4 = cell(225, 1);

%store data in cells. Odds are real and evens are imaginary
%Change file variable in loop to use different data
for i = 1:1:225
    listcomplex1{i} = [file{2*i-1, 1} + file{2*i, 1}*j];
    listcomplex2{i} = file{(2*i-1)+450, 1} + file{(2*i)+450, 1}*j;
    listcomplex3{i} = file{(2*i-1)+900, 1} + file{(2*i)+900, 1}*j;
    listcomplex4{i} = file{(2*i-1)+1350, 1} + file{(2*i)+1350, 1}*j;
    listreal{i} = file{2*i-1,1};
    listreal2{i} = file{(2*i-1)+450,1};
    listreal3{i} = file{(2*i-1)+900,1};
    listreal4{i} = file{(2*i-1)+1350,1};
end

%{
Parameters of sampling. Time of sampling = 248ns, samples = 225. 
Chirp parameters:
- T = 58us
- S = 68Mhz/us
- B = 3.944Ghz
- 30dB gain
- lamda = 4mm for 77Ghz
%}
ts = 248E-9;
fs = 1/ts;
N = 225;
t = linspace(0,58,225);
freq = 0:N-1;
freq = freq*fs/N;
val = [listreal{:}; listreal2{:}; listreal3{:}; listreal4{:}];

%Plot IF signals.
%If signal is sin(WTx-WRx) (theta)
figure(1);
subplot(2,2,1);
plot(t, val(1,:))
xlabel('Time (us)')
axis([0 58 ylim])
subplot(2,2,2);
plot(t, val(2,:))
xlabel('Time (us)')
axis([0 58 ylim])
subplot(2,2,3);
plot(t, val(3,:))
xlabel('Time (us)')
axis([0 58 ylim])
subplot(2,2,4);
plot(t, val(4,:))
xlabel('Time (us)')
axis([0 58 ylim])

%Compute FFT for each RX antenna
X = fft([listcomplex1{:}])./N;
X2 = fft([listcomplex2{:}])./N;
X3 = fft([listcomplex3{:}])./N;
X4 = fft([listcomplex4{:}])./N;
cutoff = ceil(N/2);
X = X(1:cutoff);
X2 = X2(1:cutoff);
X3 = X3(1:cutoff);
X4 = X4(1:cutoff);
freq = freq(1:cutoff);

%Plot FFT for each RX antenna
figure(2);
subplot(2,2,1);
plot(freq, abs(X));
xlabel('frequency');
ylabel('amplitude');
axis([0 2E6 ylim])

subplot(2,2,2);
plot(freq, abs(X2));
xlabel('frequency');
ylabel('amplitude');
axis([0 2E6 ylim])

subplot(2,2,3);
plot(freq, abs(X3));
xlabel('frequency');
ylabel('amplitude');
axis([0 2E6 ylim])

subplot(2,2,4);
plot(freq, abs(X4));
xlabel('frequency');
ylabel('amplitude');
axis([0 2E6 ylim])


%CFAR (Constant False Alarm Rate)
cfar = phased.CFARDetector('NumTrainingCells',8,'NumGuardCells',4);
exp_pfa = 100e-3;
cfar.ThresholdOutputPort = true;
cfar.ThresholdFactor = 'Auto';
cfar.ProbabilityFalseAlarm = exp_pfa;

%Save magnitude of FFT to f variables
f1 = abs(X);
f2 = abs(X2);
f3 = abs(X3);
f4 = abs(X4);

%Allocate cells for data of FFT
x = cell(113, 1);
x2 = cell(113, 1);
x3 = cell(113, 1);
x4 = cell(113, 1);

for k = 1:1:113
    x{k} = f1(1,k);
    x2{k} = f2(1,k);
    x3{k} = f3(1,k);
    x4{k} = f4(1,k);
end

%Cell to numbers
x = cell2mat(x);
x2 = cell2mat(x2);
x3 = cell2mat(x3);
x4 = cell2mat(x4);

%Detection of peaks
[x_detected, th] = cfar(x, 1:113);
[x_detected2, th2] = cfar(x2, 1:113);
[x_detected3, th3] = cfar(x3, 1:113);
[x_detected4, th4] = cfar(x4, 1:113);

%Plot FFT and CFAR
figure(3)
subplot(2,2,1);
plot(abs(X))
hold on
plot(th)
hold on
plot(find(x_detected), x(x_detected), 'o')
xlabel('Sample num')
axis([0 113 ylim])
hold off

subplot(2,2,2);
plot(abs(X2))
hold on
plot(th2)
hold on
plot(find(x_detected2), x2(x_detected2), 'o')
xlabel('Sample num')
axis([0 113 ylim])
hold off

subplot(2,2,3);
plot(abs(X3))
hold on
plot(th3)
hold on
plot(find(x_detected3), x3(x_detected3), 'o')
xlabel('Sample num')
axis([0 113 ylim])
hold off

subplot(2,2,4);
plot(abs(X4))
hold on
plot(th4)
hold on
plot(find(x_detected4), x(x_detected4), 'o')
xlabel('Sample num')
axis([0 113 ylim])
hold off

%number of found objects per FFT
len1 = length(find(x_detected));
len2 = length(find(x_detected2));
len3 = length(find(x_detected3));
len4 = length(find(x_detected4));

%Allocate space for list of indexes
indexRx1 = cell(1,len1);
indexRx2 = cell(1,len2);
indexRx3 = cell(1,len3);
indexRx4 = cell(1,len4);

%temp variables
temp1 = find(x_detected);
temp2 = find(x_detected2);
temp3 = find(x_detected3);
temp4 = find(x_detected4);

%Save values of indexes
for k = 1:1:len1
    indexRx1{k} = temp1 (k,1);
end

for k = 1:1:len2
    indexRx2{k} = temp2 (k,1);
end

for k = 1:1:len3
    indexRx3{k} = temp3 (k,1);
end

for k = 1:1:len4
    indexRx4{k} = temp4 (k,1);
end

%transform cell to numbers
indexRx1 = cell2mat(indexRx1);
indexRx2 = cell2mat(indexRx2);
indexRx3 = cell2mat(indexRx3);
indexRx4 = cell2mat(indexRx4);

%Allocate space for list of frequencies where object is detected
freqRx1 = cell(1, len1);
freqRx2 = cell(1, len2);
freqRx3 = cell(1, len3);
freqRx4 = cell(1, len4);


%Save respective frequencies
for k = 1:1:len1
    num = indexRx1(1,k);
    freqRx1{k} = freq(1,num);
end

for k = 1:1:len2
    num = indexRx2(1,k);
    freqRx2{k} = freq(1,num);
end

for k = 1:1:len3
    num = indexRx3(1,k);
    freqRx3{k} = freq(1,num);
end

for k = 1:1:len4
    num = indexRx4(1,k);
    freqRx4{k} = freq(1,num);
end

%Convert distances to num
freqRx1 = cell2mat(freqRx1);
freqRx2 = cell2mat(freqRx2);
freqRx3 = cell2mat(freqRx3);
freqRx4 = cell2mat(freqRx4);

%Allocate cells for distances
distRx1 = cell(1, len1);
distRx2 = cell(1, len2);
distRx3 = cell(1, len3);
distRx4 = cell(1, len4);

%Compute distances
for k = 1:1:len1
    freqtemp = freqRx1(1,k);
    distRx1{k} = freqtemp * 300E6 / (2*68E12);
end

for k = 1:1:len2
    freqtemp = freqRx2(1,k);
    distRx2{k} = freqtemp * 300E6 / (2*68E12);
end

for k = 1:1:len3
    freqtemp = freqRx3(1,k);
    distRx3{k} = freqtemp * 300E6 / (2*68E12);
end

for k = 1:1:len4
    freqtemp = freqRx4(1,k);
    distRx4{k} = freqtemp * 300E6 / (2*68E12);
end

%Convert distances to num
distRx1 = cell2mat(distRx1);
distRx2 = cell2mat(distRx2);
distRx3 = cell2mat(distRx3);
distRx4 = cell2mat(distRx4);

%Allocate cells for phases
phaseRx1 = cell(1, len1);
phaseRx2 = cell(1, len2);
phaseRx3 = cell(1, len3);
phaseRx4 = cell(1, len4);

%Compute phase of each peak
for k = 1:1:len1
    tempnum = X(1,indexRx1(1,k));
    phaseRx1{k} =  angle(tempnum)*180/pi;
end

for k = 1:1:len2
    tempnum = X2(1,indexRx2(1,k));
    phaseRx2{k} =  angle(tempnum)*180/pi;
end

for k = 1:1:len3
    tempnum = X3(1,indexRx3(1,k));
    phaseRx3{k} =  angle(tempnum)*180/pi;
end

for k = 1:1:len4
    tempnum = X4(1,indexRx4(1,k));
    phaseRx4{k} =  angle(tempnum)*180/pi;
end

%Convert cell to num
phaseRx1 = cell2mat(phaseRx1);
phaseRx2 = cell2mat(phaseRx2);
phaseRx3 = cell2mat(phaseRx3);
phaseRx4 = cell2mat(phaseRx4);