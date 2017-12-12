%Travis Morrison 
%LAI Plots 
clear; close all; clc;
%load('/Users/travismorrison/Local_Data/MATERHORN/data/tower_data/Playa_tower_averaged /playaSpring30minLinDetUTESpac3.mat');
%home laptop
%load('C:\Users\tjmor\OneDrive\Research\Data\MATERHORN\PlayaSpring_5minAvg_GPF_LinDet_2013_05_24.mat')
%Load 30 min utespac3 code
load('C:\Users\tjmor\OneDrive\Research\Data\MATERHORN\playaSpring30minLinDetUTESpac3.mat')
%t = playaSpring.tke(:,1);

%% 30 min index
start_index = 1008+14;
end_index = start_index+2*25;
START = datetime(datevec(playaSpring.H(start_index,1)))
END = datetime(datevec(playaSpring.H(end_index,1)))

%%
H_exp = playaSpring.H(start_index:end_index,2).*playaSpring.H(start_index:end_index,3).*playaSpring.H(start_index:end_index,15);
LH_exp = playaSpring.LHflux(start_index:end_index,6); % @10.4 m 
L = playaSpring.L(start_index:end_index,2);

figure()
plot(H_exp)
hold on
plot(LH_exp)
%% Radiation plot
start_index = 6410+12;
end_index = 6698+24;
% sw = table2array(radiationdata(start_index:end_index,6));
% lw = table2array(radiationdata(start_index:end_index,8));
% lwup = table2array(radiationdata(start_index:end_index,9));
sw = table2array(playa0520135min(start_index:end_index,6));
lw = table2array(playa0520135min(start_index:end_index,8));
lwup = table2array(playa0520135min(start_index:end_index,9));
figure()
plot(linspace(0,25,301),sw,'-k')
hold on 
plot(linspace(0,25,301),lw,'--k')
axis tight
legend('SWdn','LWdn')
xlabel('time [hrs]','interpreter','latex','Fontsize',25)
ylabel('Radiation [Wm$^{-2}$]','interpreter','latex','Fontsize',25)
%% Plot L, U, T, plot
L = playaSpring.L(start_index:end_index,2); 
Temp = playaSpring.derivedT(start_index:end_index,4); 
U = playaSpring.spdAndDir(start_index:end_index,3); 
figure()
subplot(3,1,1)
plot(linspace(0,25,51),L,'-k')
axis([0 25 -100 100])
%xlabel('time [hrs]','interpreter','latex','Fontsize',25)
ylabel('25-m L [m]','interpreter','latex','Fontsize',15)

subplot(3,1,2)
plot(linspace(0,25,51),Temp,'-k')
axis tight
%xlabel('time [hrs]','interpreter','latex','Fontsize',25)
ylabel('25-m $\theta_v$ [K]','interpreter','latex','Fontsize',15)

subplot(3,1,3)
plot(linspace(0,25,51),U,'-k')
axis tight
xlabel('time [hrs]','interpreter','latex','Fontsize',15)
ylabel('25-m U [ms$^{-1}$]','interpreter','latex','Fontsize',15)



%% Plot results 

%case 1: orginal Energy budget
data_case1 = table2array(resultorginaluncoupledplayaproperties);
figure()
plot(linspace(0,25,301),sw,'-.k')
hold on 
plot(linspace(0,25,301),lw,'--k')
plot(linspace(0,25,1441),data_case1((end-(24*60)):end,5),'-k')
plot(linspace(0,25,1441),data_case1((end-(24*60)):end,7),'-.r')
plot(linspace(0,25,1441),data_case1((end-(24*60)):end,8),'-r')
plot(linspace(0,25,1441),-data_case1((end-(24*60)):end,9),'-g')
axis tight
legend('SWdn','LWdn','LWup','H','LH','G')
xlabel('time [hrs]')
ylabel('E [Wm$^{-2}$]')
title('Energy Budget: Uncoupled with Playa Properties')
%%
data_case2 = table2array(resultorginalcoupledplayaproperties);
figure()
plot(linspace(0,25,301),sw,'-.k')
hold on 
plot(linspace(0,25,301),lw,'--k')
plot(linspace(0,25,1441),data_case2((end-(24*60)):end,5),'-k')
plot(linspace(0,25,1441),data_case2((end-(24*60)):end,7),'-.r')
plot(linspace(0,25,1441),data_case2((end-(24*60)):end,8),'-r')
plot(linspace(0,25,1441),-data_case2((end-(24*60)):end,9),'-g')
axis tight
legend('SWdn','LWdn','LWup','H','LH','G')
xlabel('time [hrs]')
ylabel('E [Wm$^{-2}$]')
title('Energy Budget: Coupled with Playa Properties')
%%
%case 3: uncoupled Energy budget
data_case3 = table2array(resultshaouncoupled);
figure()
plot(linspace(0,25,301),sw,'-.k')
hold on 
plot(linspace(0,25,301),lw,'--k')
plot(linspace(0,25,1441),data_case3((end-(24*60)):end,5),'-k')
plot(linspace(0,25,1441),data_case3((end-(24*60)):end,7),'-.r')
plot(linspace(0,25,1441),data_case3((end-(24*60)):end,8),'-r')
plot(linspace(0,25,1441),-data_case3((end-(24*60)):end,9),'-g')
axis tight
legend('SWdn','LWdn','LWup','H','LH','G')
xlabel('time [hrs]')
ylabel('E [Wm$^{-2}$]')
title('Energy Budget: Uncoupled with Shao Model')

%% case 3 coupled Energy budget, no bl growth
data_case4 = table2array(resultshaocoupled);
figure()
plot(linspace(0,25,301),sw,'-.k')
hold on 
plot(linspace(0,25,301),lw,'--k')
plot(linspace(0,25,1433),data_case4(:,5),'-k')
plot(linspace(0,25,1433),data_case4(:,7),'-.r')
plot(linspace(0,25,1433),data_case4(:,8),'-r')
plot(linspace(0,25,1433),-data_case4(:,9),'-g')
axis tight
legend('SWdn','LWdn','LWup','H','LH','G')
xlabel('time [hrs]')
ylabel('E [Wm$^{-2}$]')
title('Energy Budget: Coupled with Shao Model')
%% Compare terms
%H
figure()
plot(linspace(0,25,51),H_exp,'-k')
hold on
plot(linspace(0,25,1441),data_case1((end-(24*60)):end,7),'-.r')
plot(linspace(0,25,1441),data_case2((end-(24*60)):end,7),'--r')
plot(linspace(0,25,1441),data_case3((end-(24*60)):end,7),'-.b')
plot(linspace(0,25,1433),data_case4((end-1432):end,7),'--b')
xlabel('time [hrs]')
ylabel('H [Wm$^{-2}$]')
axis tight
legend('Exp. Data','Uncoupled','Coupled','Shao et al. Uncoupled','Shao et al. Coupled')
set(gcf, 'Position', [100, 100, 1100, 900])
%% L
figure()
plot(linspace(0,25,51),LH_exp)
hold on
plot(linspace(0,25,1441),data_case1((end-(24*60)):end,8),'-.r')
plot(linspace(0,25,1441),data_case2((end-(24*60)):end,8),'--r')
plot(linspace(0,25,1441),data_case3((end-(24*60)):end,8),'-.b')
plot(linspace(0,25,1433),data_case4(:,8),'--b')
xlabel('time [hrs]')
ylabel('LH [Wm$^{-2}$]')
axis tight
legend('Exp. Data','Uncoupled','Coupled','Shao et al. Uncoupled','Shao et al. Coupled')
set(gcf, 'Position', [100, 100, 1100, 900])
%%
figure()
plot(linspace(0,25,301),lwup)
hold on
plot(linspace(0,25,1441),data_case1((end-(24*60)):end,5),'-.r')
plot(linspace(0,25,1441),data_case2((end-(24*60)):end,5),'--r')
plot(linspace(0,25,1441),data_case3((end-(24*60)):end,5),'-.b')
plot(linspace(0,25,1433),data_case4(:,5),'--b')
xlabel('time [hrs]')
ylabel('LWup [Wm$^{-2}$]')
axis tight
legend('Exp. Data','Uncoupled','Coupled','Shao et al. Uncoupled','Shao et al. Coupled')
set(gcf, 'Position', [100, 100, 1100, 900])
%% Make TKE plot
e = playaSpring.tke(start_index:end_index,2);
cnt = 1;
for i = 1:2:50
    e_avg(cnt) = mean(e(i:i+1));
    cnt = cnt+1;
end

%csvwrite('tke',e_avg)
%% 