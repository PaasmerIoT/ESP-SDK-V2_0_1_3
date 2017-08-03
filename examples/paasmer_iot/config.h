#include "deviceName.h"

#define UserName "E-mail Address" //your user name in website

#define timePeriod 15000 //change the time delay as you required for sending actuator values to paasmer cloud

char *feedname[]={"feed1","feed2","feed3","feed4",...}; //feed names you use in the website

char *feedtype[]={"actuator","sensor","sensor","actuator",...}; //modify with the type of feeds i.e., actuator or sensor

int feedpin[]={16,5,4,14,...}; //modify with the pin numbers which you connected devices (actuator or sensor)
