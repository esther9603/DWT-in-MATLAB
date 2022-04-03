clc;
clear all;
close all;
delete(instrfindall);

devices = daq.getDevices;
devices(1)

s = daq.createSession('ni');
addAnalogInputChannel(s,'Dev1', 0:6, 'Voltage')
% O~5 nano17 // 6 displ // 7 loadcell 
 
s.Rate = 1000;

%calibration data of nano17
C=...
    [ -0.01161   -0.99189  -0.02361  -3.38789  -0.08339   3.37865;...
             -0.06204   3.93750   0.07139  -2.01980   0.04302  -1.91736;...
             3.69516  -0.01892   3.77562  -0.18134   3.73858  -0.07134;...
             -0.85385  24.03730  21.02695 -13.26790 -20.80709 -11.28005;...
             -24.00375   0.04741  12.11920  20.24382  12.46801 -20.86853;...
             0.19742  14.14102  -0.01204  13.58553  -0.73209  14.33131];
i = zeros(1);

while(1)
    i = i+1
        [DAQ_Data(:,:,i),timestamps(:,i)] = startForeground(s);
end


%% Sorting data
SZ = size(DAQ_Data)
for i = 0:SZ(3)-1
    temp_time(:,i+1) = timestamps(:,i+1) + i;
end

DAQ_Data1 = DAQ_Data(:,1,1);
DAQ_Data2 = DAQ_Data(:,2,1);
DAQ_Data3 = DAQ_Data(:,3,1);
DAQ_Data4 = DAQ_Data(:,4,1);
DAQ_Data5 = DAQ_Data(:,5,1);
DAQ_Data6 = DAQ_Data(:,6,1);
DAQ_Data7 = DAQ_Data(:,7,1);
time = temp_time(:,1);

for i=2:SZ(3)
    time = vertcat(time, temp_time(:,i));
    DAQ_Data1 = vertcat(DAQ_Data1,DAQ_Data(:,1,i));
    DAQ_Data2 = vertcat(DAQ_Data2,DAQ_Data(:,2,i));
    DAQ_Data3 = vertcat(DAQ_Data3,DAQ_Data(:,3,i));
    DAQ_Data4 = vertcat(DAQ_Data4,DAQ_Data(:,4,i));
    DAQ_Data5 = vertcat(DAQ_Data5,DAQ_Data(:,5,i));
    DAQ_Data6 = vertcat(DAQ_Data6,DAQ_Data(:,6,i));
    DAQ_Data7 = vertcat(DAQ_Data7,DAQ_Data(:,7,i));
end

S_DAQ_Data = [DAQ_Data1 DAQ_Data2 DAQ_Data3 DAQ_Data4 DAQ_Data5 DAQ_Data6 DAQ_Data7];

%%
pre_cal_Nano17 = [DAQ_Data1 DAQ_Data2 DAQ_Data3 DAQ_Data4 DAQ_Data5 DAQ_Data6 ];
Cal_Nano17 = C * pre_cal_Nano17' ;

Nano17_Fx = Cal_Nano17(1,:) ;
Nano17_Fy = Cal_Nano17(2,:) ;
Nano17_Fz = Cal_Nano17(3,:) ;
Nano17_Mx = Cal_Nano17(4,:) ;
Nano17_My = Cal_Nano17(5,:) ;
Nano17_Mz = Cal_Nano17(6,:) ;

Loadcell_N = DAQ_Data7*5;

%%
Time = (Timestamp)/10^6;
Pressure1 = pressure0 - pressure0(1);

PP1 = Pressure1/10

%%
figure(1)
[c,l] = wavedec(Pressure1,6,'haar')
l_s = length(Pressure1)

approx = appcoef(c,l,'haar');
[cd1,cd2,cd3,cd4,cd5,cd6] = detcoef(c,l,[1 2 3 4 5 6]);
subplot(4,2,1)
plot(Pressure1); grid on;
title('Original Data')
subplot(4,2,7)
CD3 = upcoef('d',cd3,'db1',3,l_s);
plot(CD3); grid on;
title('Level 3 Detail Coefficients')
subplot(4,2,5)
CD2 = upcoef('d',cd2,'db1',2,l_s);
plot(CD2); grid on;
title('Level 2 Detail Coefficients')
subplot(4,2,3)
CD1 = upcoef('d',cd1,'db1',1,l_s);
plot(CD1); grid on;
title('Level 1 Detail Coefficients')

subplot(4,2,2)
plot(Pressure1); grid on;
title('Original Data')
subplot(4,2,8)
CD6 = upcoef('d',cd6,'db1',6,l_s);
plot(CD6); grid on;
title('Level 6 Detail Coefficients')
subplot(4,2,6)
CD5 = upcoef('d',cd5,'db1',5,l_s);
plot(CD5); grid on;
title('Level 5 Detail Coefficients')
subplot(4,2,4)
CD4 = upcoef('d',cd4,'db1',4,l_s);
plot(CD4); grid on;
title('Level 4 Detail Coefficients')
set(gcf,'color','w');
%%
% yyaxis left;
plot(Time,Pressure1); grid on; hold on;
% plot(Time,CD6); grid on; hold on;
xlim([0 35])
set(gca,'XTick',[0:7:35]);

% ylim([-15 15]);
% set(gca,'YTick',[-15 -5 0 5 15]);
ylim([-30 300]);
set(gca,'YTick',[-30 0 100 200 300]);