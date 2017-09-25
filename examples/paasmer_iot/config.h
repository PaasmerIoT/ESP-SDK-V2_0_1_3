#include "details.h"

#define timePeriod 15000 //change the time delay as you required for sending actuator values to paasmer cloud

char *feedname[]={"feed2"}; //feed names you use in the website

char *feedtype[]={"actuator"}; //modify with the type of feeds i.e., actuator or sensor

int feedpin[]={5}; //modify with the pin numbers which you connected devices (actuator or sensor)
