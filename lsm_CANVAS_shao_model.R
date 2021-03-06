#Model of land surface, responding to atmospheric forcing
#V2(120211): initialize T with equilibrium value (determined through "uniroot")
#V3(120211): implement vegetation resistance
#V4(120218): a) instead of aerodynamic resistance formulated as simple 1/(CD*Ubar), where CD is aerodynamic transfer coefficient, now have logarithmic profile and incorporates roughness length
#            b) output results to CSV file
#V5(120218): enable atmosphere to respond to surface fluxes
#            if prescribe atmospheric temperature, can only prescribe a CONSTANT value
#V6(130209): use bulk transfer coefficient instead of roughness length for determining aerodynamic resistance, because
#            roughness length formulation had erroneously assumed wind velocity to be CONSTANT (whereas should follow logarithmic profile)
#V7(130114): addition of groundwater code by Jason H. Davison (jason.h.davison@gmail.com)
#V8(130209): rewrote ra.f, which links roughness length to CD and to aerodynamic resistance
#February 9th, 2012 by John C. Lin (John.Lin@utah.edu)

#--------------Functions-----------------#
latentheat<-function(T.c){
#Takes temperature [C] and returns value of latent heat of vaporization [J/g]
  lambda <- 2.501 - 0.0024 * T.c
  return(lambda * 1000)
} #latentheat<-function(T.c){
satvap<-function(T.c){
#Takes temp in Celsius as argument and returns saturation vapor pressure [Pa]
#NOTE:  calls upon function 'latentheat'
#3/19/1998
  kelvin<-T.c+273.15
  #return value in [J/g], so multiply by 1000 to convert into [J/kg]
  lambda<-1000*latentheat(T.c)
  #461 is Gas Constant for water vapor [J deg-1 kg-1]
  #611 & 273.15 are reference vapor pressure and reference temp., respectively
  saturated<-611*exp((lambda/461)*((1/273.15)-(1/kelvin)))
  return(saturated)
} #satvap<-function(T.c){
#--------------Physical constants--------#
Cp<-1005.7;Cv<-719 #heat capacities @ constant pressure & volume [J/kg/K] (Appendix 2 of Emanuel [1994])
g<-9.80665 #standard surface gravity [m/s2]
Rd<-287.04 #Ideal Gas Constant of DRY air [J/kg/K] (Appendix 2 of Emanuel [1994])
Rv<-461.40 #Ideal Gas Constant of water vapor [J/kg/K] (Appendix A.1.4 of Jacobson [1999])
sigma<-5.670373E-8    #Stefan-Boltzmann constant [W/m2/K4]
##########################################
vegcontrolTF<-FALSE    #vegetation control?
atmrespondTF<-TRUE    #does atmosphere respond to surface fluxes?
ABLTF<-TRUE           #does ABL growth or decay, according to surface heat fluxes?
groundwaterTF<-FALSE   #does the groundwater respond to the atmosphere?
cloudTF<-FALSE         #cloud physics response to relative humidity



############ Radiation options changed for Exp Data################

#Downward shortwave radiation
t.hr<-0:24
#a) hourly varying
#SWdn<--15*(t.hr-12)^2+800 #hourly downward shortwave radiation [W/m2]
#names(SWdn)<-t.hr
#SWdn[as.character(c(0:5,19:24))]<-0
#b) constant
#SWdn[1:length(SWdn)]<-1000

#c) examining data from IOP9, 23-24 May 2013 @ from 0700-0800UTC playa site
day<-20*24
start_index = 6410+12 #correlates to May 23 0700 UTC 
end_index = 6698+24 #correlates to May 24 0800 UTC

############## IMPORT Data ######################

#MATERHORN data
#dir for laptop
#dir <- "C:/Users/tjmor/OneDrive/Research/Data/MATERHORN/"
#dir for school computer 
dir<-"/Users/travismorrison/Documents/Local_Data/MATERHORN/data/tower_data/LAI_data/"
#filenm<-paste(dir,"playa_05_2013_5min_data_only.csv",sep="")


filenm<-paste(dir,"radiation_data.csv",sep="")
tmp<-read.csv(filenm)
tmp<-as.matrix(tmp)
Radiation_data<-tmp

filenm<-paste(dir,"tke.csv",sep="")
tmp<-read.csv(filenm,header = FALSE, stringsAsFactors=FALSE)
tmp<-as.matrix(tmp)
tke<-sapply(tmp,as.numeric)
names(tke)<-t.hr
############## assign Rad Data ######################
rad_data<-Radiation_data[start_index:end_index,]
rad_data[ ,4] = rad_data[ ,4]-7
rad_data[rad_data[,4]< 0,4] = rad_data[rad_data[,4]< 0,4]+24

SWdn = aggregate(rad_data[,6],list(rad_data[,4]),mean)
SWdn[25,1]<-24
SWdn[25,2]<-mean(Radiation_data[end_index:end_index+10,6])
SWdn = SWdn[,2]
names(SWdn)<-t.hr

LWdn =  aggregate(rad_data[,8],list(rad_data[,4]),mean)
LWdn[25,1]<-24
LWdn[25,2]<-mean(Radiation_data[end_index:end_index+10,8])
LWdn = LWdn[,2]
names(LWdn)<-t.hr

SWup = aggregate(rad_data[,7],list(rad_data[,4]),mean)
SWup[25,1]<-24
SWup[25,2]<-mean(Radiation_data[end_index:end_index+10,7])
SWup = SWup[,2]
names(SWup)<-t.hr

#Downward longwave radiation
#a)Orginal LWdn
#LWdn<-SWdn;LWdn[1:length(LWdn)]<-350 #constant downward longwave radiation [W/m2]
#b) examining data from IOP9, 23-24 May 2013 @ from 0700-0800UTC playa site
#LWdn_data<-sapply(Radiation_data[start_index:end_index,8],as.numeric)
#LWdn=rep(NA,length(t.hr))


#Land surface characteristics 
gvmax<-1/50      #max vegetation conductance [m/s]; reciprocal of vegetation resistance
albedo.c<-0.3 #mean(SWup[,2])/mean(SWdn)    #surface albedo computed from mean Rad data
albedo<-albedo.c #surface albedo
z0<-0.11e-3          #roughness length [m] for Playa (Jensen et al)
T0<-290.15 # Deep soil temperature [K] for playa (Morrison et al. 2017) 
epsilon.s<-0.93  #surface emissivity for forest, according to Jin & Liang [2006]             
                #Emissivity from for desert from Jin & Lang
dt<-60           #model timestep [s]
t.day<-10     	 #Run time in days
tmax<-t.day*24*3600  #maximum time [s]

#Air temperature
Ta.c<--0.5*(t.hr-12)^2+30  #PRESCRIBED air temperature [deg-C]
names(Ta.c)<-t.hr
Ta.c[1:length(Ta.c)]<-5    #override with CONSTANT air temperature [deg-C]

###################### Soil Properties edited for Exp Data (Morrison et al. 2017)
#heat capacity of land surface 
#D<-0.1*(dt/tmax)      #the depth of soil that temp fluctuations would penetrate [m]; 0.1m is roughly the depth that would penetrate on diurnal timescales
#D<-0.1
#D<-0.1*(1/24)          #the depth of soil that temp fluctuations would penetrate [m]; 0.1m is roughly the depth that would penetrate on diurnal timescales
D<-0.06#0.7                  #from exp data from playa (Morrison et al)
Cp.soil<-1542.8         #specific heat of soil organic material [J/kg/K]
rho.soil<-1425          #density of soil organic material [kg/m3]
nu.soil<-0.4E-6         #Thermal diffusivity for playa [m2/s]
k.soil<-0.9             #themal conductivity for playa [W/mK]
Cs<-Cp.soil*rho.soil*D #heat capacity of organic soil [J/K/m2]
alpha_soil<-0.4 #[m2/s] from exp data
#Soil properties changed for Playa

#specific humidity of air:  determine from RH, air temperature
#qair<-2/1000      #specific humidity of air [g/g]
#JHD
#  RH<-1.0     	   #Edited this to force precipitation
RH<-0.8
e<-RH*satvap(mean(Ta.c))/100  #vapor pressure [hPa]
Psurf<-1000     #surface pressure [hPa] 
qair<-(Rd/Rv)*e/Psurf   #specific humidity [g/g]

#atmospheric conditions
hmin<-100       #minimum height of atmospheric boundary layer [m]
hmax<-20000      #max height of ABL [m]
thetavM0<-(Ta.c[1]+273.15)*(1+0.61*qair) #initial virtual potential temperature [K]; Eq. 1.5.1b of Stull [1988]
Beta<-.2  #0.2       #closure hypothesis:  fraction of surface virtual potential temperature flux that determines entrainment heat flux
gamma<-5/1000   #5/1000   #slope of thetav above growing ABL [K/m]
qabove<-qair/5  #specific humidity of air above ABL [g/g] changed from 5 to 1
W<-0            #subsidence rate [m/s]
Ur<-6           #reference windspeed [m/s] at reference height zr
zr<-25          #reference height [m] where Ur applies
                #changed to height where tower data was collected 
##########################################

#function to calculate vegetation resistance
rv.f<-function(T,VPD,gvmax,Tmin.c=0,Tmax.c=60,Topt.c=30,VPDmin=1500,VPDmax=7500){
  #Jarvis [1976] type model for stomatal control
  #1) temperature function
  T.c<-T-273.15  
  fT<-(T.c-Tmin.c)*(T.c-Tmax.c)/((T.c-Tmin.c)*(T.c-Tmax.c)-(T.c-Topt.c)^2)
  fT[fT<0]<-0
  #2) vapor pressure deficit (VPD) function
  fVPD<-rep(1.0,length(VPD))
  fVPD[VPD>VPDmax]<-0      #hi VPD--stomata completely closed
  sel<-VPD>=VPDmin&VPD<=VPDmax
  slope<--1/(VPDmax-VPDmin)
  fVPD[sel]<-1+slope*(VPD[sel]-VPDmin)
  
  #final penalty function
  beta<-fT*fVPD
  gv<-beta*gvmax
  rv<-1/gv   #vegetation resistance [s/m]
  rv[rv>1E6]<-999999   #when infinite, just assign a really large number
  return(rv)
} #rv.f<-function()

rvs<-rv.f(T=273.15+20,VPD=0:4000,gvmax=gvmax)

#function to calculate aerodynamic resistance
##########orginal formulation################
ra.f<-function(Ur=1,zr=50,z0=z0,d=0,rho=1,tke=tke){
  #arguments:  Ur is reference windspeed [m/s] at reference height zr
  #            zr is reference height [m] where Ur applies
  #            z0 is roughness length [m]; 0.01m is typical value for crop
  #            d is displacement height [m]
  #            rho is air density [kg/m^3]
  k<-0.4  #von Karman constant
  tke = tke; 
 CD<-(k^2)/(log((zr-d)/z0))^2   #aerodynamic transfer coefficient
  ra<-1/(CD*Ur)                  #aerodynamic resistance [s/m]
  return(ra)
} #ra.f<-function(){
############Shao et. al. 2013 for SGS scalar formulation#########
#ra.f<-function(zr=zr,z0=z0,tke=tke){
 # z0<-11e-3 #roughness length 0.001 for deseret playa (Chaoxun et al. 2016)
  #k<-0.4 #Von Karman constant
 #C_k<-0.15 #empirical parameter ~0.15
  #l=zr #zr #mixing length, approximated as grid spacing
 #Pr<-0.3 #Prandlt Number 
  
  #calculate the Subgrid eddy diffusivity
  #K_sg<-C_k*(sqrt(tke)/k) 
  
  #Calculate the subgrid eddy diffusivity for a scalar
  #K_hsg<-K_sg*Pr^(-1)
  
  #calculate the subgrid areodynamic resistance
  #ra<-(zr/K_hsg)*log(zr/z0)
#}#ra.f<-function()


#V2(120211): initialize T with equilibrium value (determined through "uniroot")
f<-function(T,Ta,SWdn,LWdn,albedo,epsilon.s,Ur,zr,z0,gvmax=gvmax,tke=tke){
   #--------------Physical constants--------#
  Cp<-1005.7;Cv<-719 #heat capacities @ constant pressure & volume [J/kg/K] (Appendix 2 of Emanuel [1994])
  g<-9.80665 #standard surface gravity [m/s2]
  Rd<-287.04 #Ideal Gas Constant of DRY air [J/kg/K] (Appendix 2 of Emanuel [1994])
  Rv<-461.40 #Ideal Gas Constant of water vapor [J/kg/K] (Appendix A.1.4 of Jacobson [1999])
  sigma<-5.670373E-8    #Stefan-Boltzmann constant [W/m2/K4]
  #--------------Physical constants--------#
  LWup<-epsilon.s*sigma*T^4
  SWup<-albedo*SWdn
  Rnet<-SWdn-SWup+LWdn-LWup
  
  #determine sensible heat flux
  rho<-1   #air density [kg/m3]
  ra<-ra.f(zr=zr,z0=z0,tke = tke)
  H<-(Cp*rho/(ra))*(T-Ta)   #[W/m2]

  #determine latent heat flux
  beta<-1   #vegetation control (Jarvis type model)
  lambda<-1000*latentheat(T-273.15)  #latent heat of vaporization [J/kg]
  esat<-satvap(T-273.15)/100   #saturation specific humidity [hPa]
  e<-qair*Psurf/(Rd/Rv)        #vapor pressure [hPa]
  VPD<-100*(esat-e)            #vapor pressure deficit [Pa]
  qstar<-(Rd/Rv)*esat/Psurf   #saturation specific humidity [g/g]
  if(vegcontrolTF){
    rv<-rv.f(T=T,VPD=VPD,gvmax=gvmax)
  }else{
    rv<-1/gvmax
  } #if(vegcontrolTF){
  LE<-(lambda*rho/(ra+rv))*(qstar-qair) #[W/m2]

  #this should =0 when T is at equilibrium value
  return(Rnet-H-LE)
} #f<-function(T,Ta,SWdn,LWdn,albedo,epsilon.s){

xinterv<-Ta.c[1]+273.15+c(-50,50)  #interval over which to search for equil temperature
# a) use AVERAGE radiation, temps, to solve for initial equil. temperature
#Tinit<-uniroot(f,interval=xinterv,Ta=mean(Ta.c)+273.15,SWdn=mean(SWdn),LWdn=mean(LWdn),albedo=albedo,epsilon.s=epsilon.s,CD=CD,Ubar=Ubar,gvmax=gvmax)$root
# b) use initial radiation, temps to solve for initial equil. temperature
Tinit<-uniroot(f,interval=xinterv,Ta=Ta.c[1]+273.15,SWdn=SWdn[1],LWdn=LWdn[1],albedo=albedo,epsilon.s=epsilon.s,Ur=Ur,zr=zr,z0=z0,gvmax=gvmax,tke=tke[1])$root
#Impose perturbation
#Tinit<-Tinit+10


#---------------------------------------Time Loop------------------------------------------#
tcurr<-0
T<-Tinit
result_s<-NULL
h<-hmin     #initialize with minimum 

thetaM<-Ta.c[1]+273.15
qM<-qair   #initialize with prescribed specific humidity [g/g]
thetavM<-thetaM*(1+0.61*qM)   #virtual potential temperature [K];  Eq. 1.5.1b of Stull [1988]
countp = 0

dx   = 0.02  		#discretization (m)
l    = 0.5   		#length of soil model (m)
ttime = t.day*3600*24   #time in seconds (s)
k    = 1*10^-5		#Hydraulic conductivity, for GW model (m/s)
d    = 7*10^-7		#Soil water diffusivity, for GW model (m^2/s) 
count = 0		#Loop Counter
theta = matrix(0,2,(l/dx))			#Initializing saturation of ground, varies from 0-1 (-)
theta[1,1:(l/dx)] = (1:(l/dx))/(4*l/dx)+0.5	#Model initial condition for saturation
theta_s = theta[1,]
theta_save = 0
b = 1:(l/dx)*0					#Used to Solve Ax=b
theta_star = b
A = 1:(l/dx)*0					
B = A
C = A
G = A
bc_t = 0					#Top boundary condition, not used
bc_b = 1					#Bottom boundary condition
theta[,(l/dx)] = bc_b
real_time = 0
i = 1
infil = 0
evap = b
srce = 0
evap2 = 0
qstar = qM
f_c   = 0.8 #field capacity
w_p   = 0.2 #wilting point
tcc = 0 #total cloud fraction
################Ground Model Vars##############################
T_g<-c(T,0,0,0,T0) #initial profile
dz=c(0.01,0.02,0.03,0.04)
###############################################################
while(tcurr<tmax){
  countp = countp+1
  if(countp>500){
	print(paste("-------- tcurr=",round(tcurr/(3600*24)*10)/10,"[days] --------"))
  	countp = 0
        if (sum(theta_save)==0){
                theta_save = theta_s
                theta_s = 1:(l/dx)*0
                result_save = result_s
                result_s = NULL
                }
        else{
                if (groundwaterTF){
		theta_save = rbind(theta_save,theta_s[2:length(theta_s[,1]),])
                theta_s = 1:(l/dx)*0}
                result_save = rbind(result_save,result_s)
                result_s = NULL
                }
        }
  LWup<-epsilon.s*sigma*T^4   #upward longwave radiation [W/m2]
  LWdn.t<-approx(x=as.numeric(names(LWdn))*3600,y=LWdn,xout=tcurr%%(24*3600))$y  #downward shortwave radiation [W/m2]
  if(cloudTF){
	RHe = 0.5				#fitting parameter sets TCC to gain at approximately 60% humidity
	tcc = min(exp((qM/qstar-1)/(1-RHe)),1) 	#Walcek 1994 model equation (1) 	
	LWdn.t<- LWup-100+80*(tcc)
	albedo = albedo.c+0.75*(tcc)
	}
  SWdn.t<-approx(x=as.numeric(names(SWdn))*3600,y=SWdn,xout=tcurr%%(24*3600))$y  #downward shortwave radiation [W/m2]
  SWup<-albedo*SWdn.t
  #determine net radiation
  Rnet<-SWdn.t-SWup+LWdn.t-LWup

  if(atmrespondTF){
    Ta<-thetaM   #air temperature [K] is the one from zero-order jump model
    qa<-qM
  }else{
    Ta<-approx(x=as.numeric(names(Ta.c))*3600,y=Ta.c,xout=tcurr%%(24*3600))$y+273.15  #use prescribed value
    qa<-qair
  } #if(atmrespondTF){
  #determine sensible heat flux
  tke.t<-approx(x=as.numeric(names(tke))*3600,y=as.numeric(tke),xout=tcurr%%(24*3600))$y #tke[(tcurr%%(24*3600))]
  rho<-1   #air density [kg/m3]
  ra<-ra.f(zr=zr,z0=z0,tke=tke.t)
  H<-(Cp*rho/(ra))*(T-Ta)   #[W/m2]

  #determine latent heat flux
  beta<-1   #vegetation control (Jarvis type model)
  lambda<-1000*latentheat(T-273.15)  #latent heat of vaporization [J/kg]
  esat<-satvap(T-273.15)/100   #saturation specific humidity [hPa]
  e<-qa*Psurf/(Rd/Rv)        #vapor pressure [hPa]
  VPD<-100*(esat-e)            #vapor pressure deficit [Pa]
  
  qstar<-(Rd/Rv)*esat/Psurf   #saturation specific humidity [g/g]
  if(vegcontrolTF){
   rv<-rv.f(T=T,VPD=VPD,gvmax=gvmax)
  }else{
    rv<-1/gvmax
  } #if(vegcontrolTF){
  if(groundwaterTF){
    PET = (lambda*rho/(ra+rv))*(qstar-qa) #[W/m2] Calculates the potential energy rather. Not potential evapotranspiration.
    ##################
    #Raining Condtion#
    ##################
    if(qM>qstar){
		evap = evap*0     		#Evaporation is 0 when raining
		infil = (qM-qstar)*h/(1000*dx)
		qM = qstar
		qair = qstar
		qa   = qstar
		}
    #######################
    #Evaporation Condition#
    #######################
    if(qM<qstar){
		infil = 0 		#Rain/Infiltration is set to 0
                ###################
		#Evaporation Model#
		################### 

		sf_factor = (1/(1:(l/dx)))        			#scaling factor linear model set equal to 1 (-)
		sf_factor[(l/dx-5):(l/dx)] = 0				#Moving evaporation away from influence of BC
		sf_factor = (sf_factor/sum(sf_factor))			#scaling factor linear model set equal to 1 (-)

		av_theta = ((theta[i,]-w_p)/(f_c-w_p))  		#Available Mositure Content (-)
		PET_frac = ((PET/lambda*dt)/1000)/dx			#PET represented as MC (-) 
		evap = sf_factor * av_theta * PET_frac			#Evaporation represented as moisture content (-)
		}
        srce   = infil-sum(evap)    
    	LE  = sum(evap)*(lambda/dt)*(dx*1000)  #[W/m2] 
  } else{#LE = (lambda*rho/(ra+rv))*(qstar-qa)} #[W/m2]
    LE=.18*H} #Overide latent HF with LE = H/Bowen Ratio
    
  ###########################################determine ground heat flux 
  #a) orginal method(as residual)
  G<-Rnet-LE-H  
  #G<-((2*pi*Cp.soil*D)/86400)*(T-T0)
  #update temperature 
  dT<-(G/Cs)*dt
  #dT<-(-G/k.soil)*D
  T<-T+dT
 
  
  #if want atmosphere to respond
  #Based on "zero-order jump" or "slab" model of convective boundary layer, described in Pg. 151~155 of Garratt [1992]
  if(atmrespondTF){
    #update ABL-averaged q
    #calculate surface virtual heat flux
    lambda<-latentheat(T-273.15)  #latent heat of vaporization [J/g]
    E<-LE/lambda   #surface moisture flux [g/m^2/s] 
    F0theta<-H/Cp  #potential heat flux [K-kg/m^2/s]
    F0thetav<-F0theta+0.073*lambda*E/Cp #virtual heat flux [K-kg/m^2/s]
    if(ABLTF){
       Fhthetav<--1*Beta*F0thetav   #closure hypothesis (Eq. 6.15 of Garratt [1992])
       #calculate ABL growth rate
       dh.dt<-(1+2*Beta)*F0thetav/(gamma*h)
       if(F0thetav<=0.00)dh.dt<-0   #ABL collapses
       
    }else{
      dh.dt<-0
      Fhthetav<-0
    } #if(ABLTF){
    #calculate entrainment flux of humidity
    deltaq<-qabove - qM
    Fhq<--1*rho*deltaq*(dh.dt-W)*1000  #entrainment flux of humidity [g/m2/s] NOTE:  assume CONSTANT air density!
    dq.dt<-(E-Fhq)/(rho*1000*h) #change of humidity in ABL [1/s]; NOTE:  assume CONSTANT air density!
    qM<-qM+dq.dt*dt                #updated qM [g/g]
    #update ABL-averaged thetav
    dthetavM.dt<-(F0thetav-Fhthetav)/h  #change of thetav in ABL [K-kg/m^3/s]
    dthetavM.dt<-dthetavM.dt/rho        #[K-kg/m^3/s]=>[K/s]
    thetavM<-thetavM+dthetavM.dt*dt
    thetaM<-thetavM/(1+0.61*qM)   #potential temperature, from virtual pot temp [K];  Eq. 1.5.1b of Stull [1988]
    #update ABL height
    h<-h+dh.dt*dt
    if(F0thetav<=0.00&ABLTF)h<-hmin    #override value:  ABL collapses
    if(h>=hmax)h<-hmax #added max Bl depth
  } #if(atmrespondTF){
  if(groundwaterTF){
	theta[i,1] = theta[i,2]#bc_t
        theta[i,(l/dx)] = bc_b#theta[i,(l/dx-1)]
        ############################
        #Forward Euler (Predictor)
        ############################
		#evap = evap*0
		#infil = infil*0
		thetaf = theta[i,3:(l/dx)]
                thetan = theta[i,2:(l/dx-1)]
                thetab = theta[i,1:(l/dx-2)]
                theta_star[2:(l/dx-1)] = theta[i,2:(l/dx-1)]+dt*(d/dx*(thetaf+thetan)/2*(thetaf-thetan)/dx-d/dx*(thetab+thetan)/2*(thetan-thetab)/dx-k*(thetaf-thetab)/(2*dx))
                theta_star = theta_star-evap
		theta_star[2] = theta_star[2]+infil 
		theta_star[1] = theta_star[2] 
                theta_star[l/dx] = bc_b

                ###########################
                #Crank-Nicolson
                ###########################
                theta_starf = theta_star[3:(l/dx)]
                theta_starn = theta_star[2:(l/dx-1)]
                theta_starb = theta_star[1:(l/dx-2)]
                theta_starph = (theta_starf+theta_starn)/2
                theta_starnh = (theta_starn+theta_starb)/2


                mu = d*dt/(2*dx^2)
                A  = -mu*theta_starnh - k*dt/(4*dx)
                B  = 1 + mu*theta_starph + mu*theta_starnh #+k*dt/(2*dx)
                C  = -mu*theta_starph + k*dt/(4*dx)
                GG  = -A*thetab+(2-B)*thetan-C*thetaf

                a  = matrix(0,l/dx,l/dx)
                diag(a[2:(l/dx-1),1:(l/dx)]) = A
                diag(a[2:(l/dx-1),2:(l/dx)]) = B
                diag(a[2:(l/dx-1),3:(l/dx)]) = C
                b[2:(l/dx-1)] = GG

                ############################
                #Boundary Conditions
                ############################
                a[1,1] = 1
		b = b-evap  
		b[2] = b[2]+infil
                b[1] = theta[i,2]+infil-evap[2]
                a[(l/dx),(l/dx)] = 1
                b[l/dx] = bc_b#b[l/dx-1]
		a[(l/dx-1),(l/dx-1)] = a[(l/dx-1),(l/dx-1)]+10^10
		b[(l/dx-1)] = 10^10*bc_b+b[(l/dx-1)]

                theta[i+1,]  = solve(a,b)
		theta[i+1,1]   = theta[i+1,2]#bc_t
                theta[theta>1] = 1
		theta[i,(l/dx)] = bc_b#theta[i,((l/dx)-1)]
                count = count+1
                real_time = (dt*i)/(3600*24) #time in day fractions
                real_time = round(real_time)
		i = 1
		theta_s=rbind(theta_s,theta[i+1,])
		theta[i,] = theta[i+1,]
  } #if(groundwaterTF){
  evap2 = sum(evap)
  tmp<-c(tcurr,T,Ta,LWup,Rnet,H,LE,G,dT,qstar,qa,ra,rv,h,qM,thetavM,thetaM)
  if(groundwaterTF)tmp<-c(tcurr,T,Ta,LWup,Rnet,H,LE,G,dT,PET,qstar,qa,ra,rv,h,qM,thetavM,thetaM,infil,evap2,srce,LWdn.t,SWdn.t,SWup,F0thetav,tcc)
  result_s<-rbind(result_s,tmp)
  tcurr<-tcurr+min(c(dt,tmax-tcurr))
} #while(tcurr<ttmax){
#---------------------------------------Time Loop------------------------------------------#
result = rbind(result_save,result_s)
if(groundwaterTF){
  dimnames(result)<-list(NULL,c("time","T","Ta","LWup","Rnet","H","LE","G","dT","PET","qstar","qair","ra","rv","h","qM","thetavM","thetaM","infil","evap","srce","LWdn","SWdn","SWup","F0","tcc"))
}else{
  dimnames(result)<-list(NULL,c("time","T","Ta","LWup","Rnet","H","LE","G","dT",
                              "qstar","qair","ra","rv","h","qM","thetavM","thetaM"))
} #if(groundwaterTF){
filenm<-"result.csv"
write.csv(result,file=filenm)
print(paste(filenm,"written out"))

#generate movie of moisture content
if (groundwaterTF){
  theta = theta_save = rbind(theta_save,theta_s[2:length(theta_s[,1]),])
  X11()
  j = count
  for (i in 1:j){
	real_time = (dt*i)/(3600*24) #time in day fractions
        real_time = round(real_time)
        if (count>10){
		title_gr =  (paste("Run Time ", real_time , " (days)"))
                plot(theta[i,2:(l/dx-1)],-(1:(l/dx-2))*dx, xlab = "Moisture Content (-)", ylab = "Depth Below Surface (m)",main = title_gr,xlim=c(0, 1), ylim=c(-l,0))
                count = 0
                }
	count = count+1
  } #for (i in 1:j){
} #if (groundwaterTF){

#text on plot 
xmain<-paste("vegcontrol=",vegcontrolTF)
xmain<-paste(xmain,"  atmrespondTF=",atmrespondTF)
xmain<-paste(xmain,"\nABLTF=",ABLTF)
xmain<-paste(xmain,"  groundwaterTF=",groundwaterTF)
xmain<-paste(xmain,"  cloudTF=",cloudTF)
#regenerate VPD from qstar and qair 
e<-result[,"qair"]*Psurf/(Rd/Rv)      #vapor pressure [hPa]
esat<-result[,"qstar"]*Psurf*(Rv/Rd)  #saturation vapor pressure [hPa]
VPD<-100*(esat-e)                     #vapor pressure deficit [Pa]


#--------generate 4 different plots in one window, with 2*2 configuration---------#
X11();par(mfrow=c(2,2),cex.main=0.7)   
ylims<-range(result[,c("T","Ta")]-273.15)
plot(result[,"time"]/3600,result[,"T"]-273.15,type="l",xlab="Time [hour]",ylab="Temperature [deg-C]",
     cex.axis=1.3,cex.lab=1.3,lwd=2,ylim=ylims,main=xmain)
lines(result[,"time"]/3600,result[,"Ta"]-273.15,lty=2,lwd=2)
legend(x="topright",c("Tsurf","Tair"),lwd=2,lty=c(1,2))

plot(result[,"time"]/3600,VPD,type="l",xlab="Time [hour]",ylab="VPD [Pa]",lwd=2,
     cex.axis=1.3,cex.lab=1.3,main=xmain)

ylims<-range(result[,c("qstar","qair")]*1000)
plot(result[,"time"]/3600,result[,"qstar"]*1000,type="l",xlab="Time [hour]",ylab="Specific humidity [g/kg]",
     cex.axis=1.3,cex.lab=1.3,lwd=2,ylim=ylims,main=xmain)
lines(result[,"time"]/3600,result[,"qair"]*1000,lty=2,lwd=2)
legend(x="topright",c("qstar","qair"),lwd=2,lty=c(1,2))

ylims<-range(result[,c("ra","rv")])
plot(result[,"time"]/3600,result[,"ra"],type="l",xlab="Time [hour]",ylab="Resistances [s/m]",
     cex.axis=1.3,cex.lab=1.3,lwd=2,ylim=ylims,main=xmain,col="yellow")
lines(result[,"time"]/3600,result[,"rv"],lty=1,lwd=2,col="lightgreen")
legend(x="topright",c("raero","rveg"),lwd=2,lty=c(1),col=c("yellow","lightgreen"))
dev.copy(png,"T_q_r_VPD.png");dev.off()
#--------generate 4 different plots in one window, with 2*2 configuration---------#


X11()
matplot(result[,"time"]/3600,result[,c("Rnet","LWup","H","LE","G")],type="l",lty=c(1,2,1,1,1),
        cex.axis=1.5,cex.lab=1.5,col=c("black","black","orange","blue","darkgreen"),lwd=2,xlab="Time [hr]",ylab="Energy Fluxes [W/m2]")
legend(x="topright",c("Rnet","LWup","H","LE","G"),col=c("black","black","orange","blue","darkgreen"),lwd=2,lty=c(1,2,1,1,1))
title(main=xmain)
dev.copy(png,"Energyfluxes.png",pointsize = 30, width = 1800, height = 1200);dev.off()

if(atmrespondTF){
  X11()
  plot(result[,"time"]/3600,result[,"h"],type="l",xlab="Time [hour]",ylab="ABL height [m]",
     cex.axis=1.3,cex.lab=1.3,lwd=2,main=xmain)
  dev.copy(png,"ABLht.png");dev.off()
} #if(atmrespondTF){


if(groundwaterTF){
  X11()
  qr<-result[,"qair"]/result[,"qstar"]
  plot(result[,"time"]/3600,qr,xlab="Time [hour]",ylab="qair/qstar",cex.axis=1.3,cex.lab=1.3,lwd=2,main=xmain)

  X11()
  plot(result[,"time"]/3600,result[,"srce"],xlab="Time [hour]",ylab="Infil - Evap",cex.axis=1.3,cex.lab=1.3,lwd=2,main=xmain)
} #if(groundwaterTF){
