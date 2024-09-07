close all
VelAccM = cumtrapz(Acc(:,2)*9.81).*9.765625e-5;
PosAccM = cumtrapz(VelAccM).*9.765625e-5; 

Fp = 100;
Fst = 110;
Ap = 1;
Ast = 30;
Fs = 10e3;

d = designfilt('lowpassiir','PassbandFrequency',Fp,...
  'StopbandFrequency',Fst,'PassbandRipple',Ap,...
  'StopbandAttenuation',Ast,'SampleRate',Fs,'DesignMethod','butter');
y = filtfilt(d,VelL);
figure
plot(y(:,1),[y(:,2),VelL(:,2)])
figure
plot(VelL(:,1),[VelAccM,VelL(:,2)]);
figure
plot(VelL(:,1),[PosL(:,2),PosAccM,PosAcc(:,2)*9.81]);

Fp = 800;
Fst = 1000;
Ap = 0.1;
Ast = 30;
Fs = 10e3;

d2 = designfilt('lowpassiir','PassbandFrequency',Fp,...
  'StopbandFrequency',Fst,'PassbandRipple',Ap,...
  'StopbandAttenuation',Ast,'SampleRate',Fs,'DesignMethod','butter');
ya = filtfilt(d2,Acc);
figure
plot(Acc(:,1),[Acc(:,2),ya(:,2)]);