%Travis Morrison 
%LAI Plots 
%clear; close all; clc;
load('/Users/travismorrison/Local_Data/MATERHORN/data/tower_data/Playa_tower_averaged /playaSpring30minLinDetUTESpac3.mat');

t = playaSpring.tke(:,1);

start_index = 1008+(7*2);
end_index = start_index+50;
START = datetime(datevec(t(start_index)))
END = datetime(datevec(t(end_index)))
%%
H_exp = playaSpring.H(start_index:end_index,2).*playaSpring.H(start_index:end_index,3).*playaSpring.H(start_index:end_index,9);
LH_exp = playaSpring.LHflux(start_index:end_index,6); % @10.4 m 
L = playaSpring.L(start_index:end_index,2);

figure()
plot(H_exp)
hold on
plot(L_exp)
%% Radiation plot
start_index = 6410+12;
end_index = 6698+24;
sw = table2array(radiationdata(start_index:end_index,6));
lw = table2array(radiationdata(start_index:end_index,8));
lwup = table2array(radiationdata(start_index:end_index,9));
figure()
plot(linspace(0,25,301),sw,'-k')
hold on 
plot(linspace(0,25,301),lw,'--k')
axis tight
legend('SWdn','LWdn')
xlabel('time [hrs]')
ylabel('Radiation [Wm$^{-2}$]','interpreter','latex')

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
data_case3 = table2array(resultShaouncoupled);
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
data_case4 = table2array(resultShaoatmcouplednoBLgrowth);
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
plot(linspace(0,25,1433),data_case4(:,7),'--b')
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
set(gcf, 'Position', [100, 100, 1500, 900])
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
set(gcf, 'Position', [100, 100, 1500, 900])
%% Make TKE plot
e = playaSpring.tke(start_index:end_index,2);
cnt = 1;
for i = 1:2:50
    e_avg(cnt) = mean(e(i:i+1));
    cnt = cnt+1;
end

%csvwrite('tke',e_avg)
%% 