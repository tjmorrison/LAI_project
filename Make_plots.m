%Travis Morrison 
%LAI Plots 
clear; close all; clc;
%%
%load('/Users/travismorrison/Local_Data/MATERHORN/data/tower_data/Playa_tower_averaged /playaSpring30minLinDetUTESpac3.mat');
%home laptop
%load('C:\Users\tjmor\OneDrive\Research\Data\MATERHORN\PlayaSpring_5minAvg_GPF_LinDet_2013_05_24.mat')
%Load 30 min utespac3 code
load('C:\Users\tjmor\OneDrive\Research\Data\MATERHORN\playaSpring30minLinDetUTESpac3.mat')

%uiopen('C:\Users\tjmor\OneDrive\Documents\classes\LAI\Final_project\data\orginal_coupled.csv',1)
uiopen('C:\Users\tjmor\OneDrive\Documents\classes\LAI\Final_project\data\orginal_uncoupled.csv',1)
%t = playaSpring.tke(:,1);
%% Make energy budget plot & T plot with simulated data 

figure()
plot(linspace(0,25,1441),table2array(orginalcoupled((end-1440):end,3))-273.15)
hold on
plot(linspace(0,25,1441),table2array(orginalcoupled((end-1440):end,4))-273.15)
legend('T_s','T(z=26 m)')
ylabel('T [$^{o}$C]','interpreter','latex','Fontsize',15)
xlabel('time [hour]','interpreter','latex','Fontsize',15)

figure()
plot(linspace(0,25,1441),table2array(orginalcoupled((end-1440):end,6)))
hold on
plot(linspace(0,25,1441),table2array(orginalcoupled((end-1440):end,7)))
plot(linspace(0,25,1441),table2array(orginalcoupled((end-1440):end,8)))
plot(linspace(0,25,1441),table2array(orginalcoupled((end-1440):end,9)))
legend('R_n','H','H_L','G')
ylabel('E [Wm$^{-2}$]','interpreter','latex','Fontsize',15)
xlabel('time [hour]','interpreter','latex','Fontsize',15)

%%
figure()
plot(linspace(0,25,1441),table2array(orginaluncoupled((end-1440):end,3))-273.15)
hold on
plot(linspace(0,25,1441),table2array(orginaluncoupled((end-1440):end,4))-273.15)
legend('T_s','T(z=26 m)')
ylabel('T [$^{o}$C]','interpreter','latex','Fontsize',15)
xlabel('time [hour]','interpreter','latex','Fontsize',15)

figure()
plot(linspace(0,25,1441),table2array(orginaluncoupled((end-1440):end,6)))
hold on
plot(linspace(0,25,1441),table2array(orginaluncoupled((end-1440):end,7)))
plot(linspace(0,25,1441),table2array(orginaluncoupled((end-1440):end,8)))
plot(linspace(0,25,1441),table2array(orginaluncoupled((end-1440):end,9)))
legend('R_n','H','H_L','G')
ylabel('E [Wm$^{-2}$]','interpreter','latex','Fontsize',15)
xlabel('time [hour]','interpreter','latex','Fontsize',15)
%%
figure()
plot(linspace(0,25,1441),table2array(resultshaocoupled((end-1440):end,3))-273.15)
hold on
plot(linspace(0,25,1441),table2array(resultshaocoupled((end-1440):end,4))-273.15)
legend('T_s','T(z=26 m)')
ylabel('T [$^{o}$C]','interpreter','latex','Fontsize',15)
xlabel('time [hour]','interpreter','latex','Fontsize',15)

figure()
plot(linspace(0,25,1441),table2array(resultshaocoupled((end-1440):end,6)))
hold on
plot(linspace(0,25,1441),table2array(resultshaocoupled((end-1440):end,7)))
plot(linspace(0,25,1441),table2array(resultshaocoupled((end-1440):end,8)))
plot(linspace(0,25,1441),table2array(resultshaocoupled((end-1440):end,9)))
legend('R_n','H','H_L','G')
ylabel('E [Wm$^{-2}$]','interpreter','latex','Fontsize',15)
xlabel('time [hour]','interpreter','latex','Fontsize',15)
%%
figure()
plot(linspace(0,25,1441),table2array(resultshaouncoupled((end-1440):end,3))-273.15)
hold on
plot(linspace(0,25,1441),table2array(resultshaouncoupled((end-1440):end,4))-273.15)
legend('T_s','T(z=26 m)')
ylabel('T [$^{o}$C]','interpreter','latex','Fontsize',15)
xlabel('time [hour]','interpreter','latex','Fontsize',15)

figure()
plot(linspace(0,25,1441),table2array(resultshaouncoupled((end-1440):end,6)))
hold on
plot(linspace(0,25,1441),table2array(resultshaouncoupled((end-1440):end,7)))
plot(linspace(0,25,1441),table2array(resultshaouncoupled((end-1440):end,8)))
plot(linspace(0,25,1441),table2array(resultshaouncoupled((end-1440):end,9)))
legend('R_n','H','H_L','G')
ylabel('E [Wm$^{-2}$]','interpreter','latex','Fontsize',15)
xlabel('time [hour]','interpreter','latex','Fontsize',15)
%% BL depth
figure()
plot(linspace(0,25,1441),table2array(resultshaocoupled((end-1440):end,15)))
ylabel('h [m]','interpreter','latex','Fontsize',15)
xlabel('time [hour]','interpreter','latex','Fontsize',15)

figure()
plot(linspace(0,25,1441),table2array(orginalcoupled((end-1440):end,15)))
ylabel('h [m]','interpreter','latex','Fontsize',15)
xlabel('time [hour]','interpreter','latex','Fontsize',15)
%% 30 min index
start_index = 1008+14;
end_index = start_index+2*25;
START = datetime(datevec(playaSpring.H(start_index,1)))
END = datetime(datevec(playaSpring.H(end_index,1)))
START_1Hz = datetime(datevec(playaSpring.Playa_1HZ(start_index,1)))
%% Plot results against exp data

H_exp = playaSpring.H(start_index:end_index,2).*playaSpring.H(start_index:end_index,3).*playaSpring.H(start_index:end_index,15);
LH_exp = playaSpring.LHflux(start_index:end_index,6); % @10.4 m 
L = playaSpring.L(start_index:end_index,2); %Obukhov Length
T = playaSpring.Playa_1HZ(start_index:end_index,2);

%% T_air
figure()
plot(linspace(0,25,51),T,'-k')
hold on 
plot(linspace(0,25,1441),table2array(orginaluncoupled((end-1440):end,4))-273.15,'--b')
plot(linspace(0,25,1441),table2array(orginalcoupled((end-1440):end,4))-273.15,'-b')
plot(linspace(0,25,1441),table2array(resultshaouncoupled((end-1440):end,4))-273.15,'--r')
plot(linspace(0,25,1441),table2array(resultshaocoupled((end-1440):end,4))-273.15,'-r')
legend('Obs','HFMO NC','HFMO C','HFSH13 NC','HFSH13 C')
ylabel('T [$^{o}$C]','interpreter','latex','Fontsize',15)
xlabel('time [hour]','interpreter','latex','Fontsize',15)
%% H
figure()
plot(linspace(0,25,51),H_exp,'-k')
hold on 
plot(linspace(0,25,1441),table2array(orginaluncoupled((end-1440):end,7)),'--b')
plot(linspace(0,25,1441),table2array(orginalcoupled((end-1440):end,7)),'-b')
plot(linspace(0,25,1441),table2array(resultshaouncoupled((end-1440):end,7)),'--r')
plot(linspace(0,25,1441),table2array(resultshaocoupled((end-1440):end,7)),'-r')
legend('Obs','HFMO NC','HFMO C','HFSH13 NC','HFSH13 C')
ylabel('H [Wm$^{-2}$]','interpreter','latex','Fontsize',15)
xlabel('time [hour]','interpreter','latex','Fontsize',15)
%% H_L
figure()
plot(linspace(0,25,51),LH_exp,'-k')
hold on 
plot(linspace(0,25,1441),table2array(orginaluncoupled((end-1440):end,8)),'--b')
plot(linspace(0,25,1441),table2array(orginalcoupled((end-1440):end,8)),'-b')
plot(linspace(0,25,1441),table2array(resultshaouncoupled((end-1440):end,8)),'--r')
plot(linspace(0,25,1441),table2array(resultshaocoupled((end-1440):end,8)),'-r')
legend('Obs','HFMO NC','HFMO C','HFSH13 NC','HFSH13 C')
ylabel('H$_L$ [Wm$^{-2}$]','interpreter','latex','Fontsize',15)
xlabel('time [hour]','interpreter','latex','Fontsize',15)
%% Radiation plot
start_index = 6410+12;
end_index = 6698+24;
% sw = table2array(radiationdata(start_index:end_index,6));
% lw = table2array(radiationdata(start_index:end_index,8));
% lwup = table2array(radiationdata(start_index:end_index,9));
sw = table2array(playa0520135min(start_index:end_index,6));
lw = table2array(playa0520135min(start_index:end_index,8));
lwup = table2array(playa0520135min(start_index:end_index,9));
swup = table2array(playa0520135min(start_index:end_index,7));
Rn = table2array(playa0520135min(start_index:end_index,10));
G = table2array(efsplayaderek0520135min(start_index:end_index,6));
%compare rad 
%Rn
figure()
plot(linspace(0,25,301),Rn,'-k')
hold on
plot(linspace(0,25,1441),table2array(orginaluncoupled((end-1440):end,6)),'--b')
plot(linspace(0,25,1441),table2array(orginalcoupled((end-1440):end,6)),'-b')
plot(linspace(0,25,1441),table2array(resultshaouncoupled((end-1440):end,6)),'--r')
plot(linspace(0,25,1441),table2array(resultshaocoupled((end-1440):end,6)),'-r')
legend('Obs','HFMO NC','HFMO C','HFSH13 NC','HFSH13 C')
ylabel('R$_n$ [Wm$^{-2}$]','interpreter','latex','Fontsize',15)
xlabel('time [hour]','interpreter','latex','Fontsize',15)

%compare rad 
%lwup
figure()
plot(linspace(0,25,301),lwup,'-k')
hold on
plot(linspace(0,25,1441),table2array(orginaluncoupled((end-1440):end,5)),'--b')
plot(linspace(0,25,1441),table2array(orginalcoupled((end-1440):end,5)),'-b')
plot(linspace(0,25,1441),table2array(resultshaouncoupled((end-1440):end,5)),'--r')
plot(linspace(0,25,1441),table2array(resultshaocoupled((end-1440):end,5)),'-r')
legend('Obs','HFMO NC','HFMO C','HFSH13 NC','HFSH13 C')
ylabel('L$_{\uparrow}$ [Wm$^{-2}$]','interpreter','latex','Fontsize',15)
xlabel('time [hour]','interpreter','latex','Fontsize',15)
%% G
figure()
plot(linspace(0,25,301),-G,'-k')
hold on
plot(linspace(0,25,1441),table2array(orginaluncoupled((end-1440):end,9)),'--b')
plot(linspace(0,25,1441),table2array(orginalcoupled((end-1440):end,9)),'-b')
plot(linspace(0,25,1441),table2array(resultshaouncoupled((end-1440):end,9)),'--r')
plot(linspace(0,25,1441),table2array(resultshaocoupled((end-1440):end,9)),'-r')
legend('Obs','HFMO NC','HFMO C','HFSH13 NC','HFSH13 C')
ylabel('G [Wm$^{-2}$]','interpreter','latex','Fontsize',15)
xlabel('time [hour]','interpreter','latex','Fontsize',15)
%%
%EXP data
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