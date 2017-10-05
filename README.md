# ESP-SDK-V2_0_1_3
**Paasmer IoT SDK** for **ESP based Devices** like **NodeMCU** and **Adafruit Huzzah**.

## Overview

The **Paasmer SDK** for **ESP based Devices** is a collection of source files that enables you to connect to the Paasmer IoT Platform. It includes the transport client for **MQTT** with **TLS** support.  It is distributed in source form and intended to be built into customer firmware along with application code, other libraries and RTOS.

## Features

The **ESP-SDK-V2_0_1_3** simplifies access to the Pub/Sub functionality of the **Paasmer IoT** broker via **MQTT**. The SDK has been tested to work with the **Paasmer IoT Platform** and **ESP based Devices** like **NodeMCU** and **Adafruit Huzzah**.

## MQTT Connection

The **ESP-SDK-V2_0_1_3** provides functionality to create and maintain a mutually authenticated TLS connection over which it runs **MQTT**. This connection is used for any further publish operations and allow for subscribing to **MQTT** topics which will call a configurable callback function when these topics are received.

## Pre Requisites

Registration on the[portal] (http://developers.paasmer.co) is necessary to connect the device to the **Paasmer IoT Platform** .The SDK has been tested on the Ubuntu 16.10 LTS host with **NodeMCU** and **Adafruit Huzzah**.

* The following support SDK's and toolchain must be installed on the host device.
* ESP OPEN SDK from [here](https://github.com/pfalcon/esp-open-sdk/).
* Dependencies for the above ESP OPEN SDK are highlighted in the above link. 
* Xtensa Tool Chain would be created if ESP OPEN SDK is installed correctly.

## Installation

* Download the SDK or clone it using the command below.

```
$ git clone github.com/PaasmerIoT/ESP-SDK-V2_0_1_3.git
$ cd ESP-SDK-V2_0_1_3
```

* Supply your WiFi credentials, edit `include/ssid_config.h` defining the two macro defines.

```c
#define WIFI_SSID "my wifi ssid"
#define WIFI_PASS "my secret password"
```

* To install dependencies, follow the commands below

```
$ cd examples/paasmer_iot
$ sudo ./install.sh
```

This will take some time to install the required softwares and packages.

## Device Registration
The Device Registration can be done only using command line.

#### Using Command line

* To register the device to the Paasmer IoT Platform, the following command need to be executed.

```
$ cd examples/paasmer_iot
$ sudo ./install.sh
```

* Upon successful completion of the above command, the following commands need to be executed.

```
$ sudo su
$ source ~/.bashrc
$ PAASMER
$ sudo sed -i 's/alias PAASMER/#alias PAASMER/g' ~/.bashrc
$ exit
```

* Edit the config.h file to include the user name(Email), device name, feed names and GPIO pin details.

```c
#include "details.h"

#define timePeriod 15000 //change the time delay as you required for sending actuator values to paasmer cloud

char *feedname[]={"feed2"}; //feed names you use in the website

char *feedtype[]={"actuator"}; //modify with the type of feeds i.e., actuator or sensor

int feedpin[]={5}; //modify with the pin numbers which you connected devices (actuator or sensor)
```

* Compile the code and flash the code onto the ESP based device.

```
cd ../../
make flash -j4 -C examples/paasmer_iot ESPPORT=/dev/ttyUSB0
```
*  **_The USB port number may vary based on the port_**

* The device would now be connected to the Paasmer IoT Platform and publishing sensor values at specified intervals.

## Support

The support forum is hosted on the GitHub where issues can be identified and the Team from Paasmer would be taking up requests and resolving them. You could also send a mail to support@paasmer.co with the issue details for resolution.

## Note

The Paasmer IoT ESP-SDK-V2_0_1_3 utilizes the features provided by ESP-OPEN-SDK and ESP-OPEN-RTOS
