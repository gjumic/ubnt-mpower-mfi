
Ubiquity mPower mFi Smart Plug Monitor and Controller.
============

## About

The [tp-link Wi-Fi Smart Plug model HS100](http://www.tp-link.us/products/details/HS100.html) and [tp-link Wi-Fi Smart Plug model HS110](https://www.kasasmart.com/us/products/smart-plugs/kasa-smart-plug-energy-monitoring-hs110) are an embedded Linux computer with a Wifi chip, a 110/220 V AC relay with a 15 A current limit, and a grounded electrical socket. You pair with it by establishing an ad-hoc network between the plug and a smartphone (also called Wi-Fi direct). After giving your router's SSID and access information, the plug connects to it and you can control the plug with the app provided by tp-link, called Kasa. One downside of using Kasa is that it's really not much more than a wall-switch in an app, though it does have pretty rich timer features which are nice. But you can't do things like turn the light on or off in response to events on the internet. Tp-link does provide a network control mode, but you have to pass control of your plug over to them, which isn't particularly great if you endeavor to remain the master of your own domain, haha only serious.


## Features

1. Output sensor data in JSON format
2. Turn each Smart Plug port on and off
3. You can reset each port which turns it off and then on after 5 seconds
4. You can reset all ports on the Smart Plug
5. Inject data into InfluxDB with Telegraf
6. Live monitoring with Grafana

## Control and Monitoring

Script uses REST API to control and monitor UBNT mPower mFi

Print help:
```sh
./mpower.sh -h
Usage: ./mpower.sh [arguments]
        Argument list:
        -u:      mFi Username
        -p:      mFi Password
        -i:      mFi IP Address
        -c:      Command to execute  [ on | off | restart | restart-all | emeter ]
                 on             -        Turns on power on relay number provided with -r
                 off            -        Turns off power on relay number provided with -r
                 restart        -        Turns off power then on after 5 seconds on relay number provided with -r
                 restart-all    -        Turns off power then on after 5 seconds on all relays
                 emeter         -        Output data in json format
        -r:      Execute [ on | off | restart ] on which relay/port
        -h:      Display this help
```

Turn on example:
```sh
./mpower.sh -u ubnt -p ubnt -i 192.168.1.10 -c on -r 1
```
This will turn on relay on port 1.

Turn off example:
```sh
./mpower.sh -u ubnt -p ubnt -i 192.168.1.10 -c off -r 1
```
This will turn off relay on port 1.

Restart example:
```sh
./mpower.sh -u ubnt -p ubnt -i 192.168.1.10 -c restart -r 1
```
This will restart relay on port 1.

Restart all ports example:
```sh
./mpower.sh -u ubnt -p ubnt -i 192.168.1.10 -c restart-all
```
This will restart all relays.

Get sensor output example
```sh
./mpower.sh -u ubnt -p ubnt -i 192.168.1.10 -c emeter
```
```json
{
  "sensors": [
    {
      "port": 1,
      "id": "5e514333e4b0c71a0d50006a",
      "label": "Soyuz",
      "model": "Outlet",
      "output": 1,
      "power": 832.103851675,
      "enabled": 1,
      "current": 3.650768101,
      "voltage": 230.971436262,
      "powerfactor": 0.986813336,
      "relay": 1,
      "lock": 0
    },
    {
      "port": 2,
      "id": "5e51433ae4b0c71a0d50006b",
      "label": "Rover",
      "model": "Outlet",
      "output": 1,
      "power": 820.146374702,
      "enabled": 1,
      "current": 3.597173988,
      "voltage": 230.938940525,
      "powerfactor": 0.987262761,
      "relay": 1,
      "lock": 0
    },
    {
      "port": 3,
      "id": "5e51433fe4b0c71a0d50006c",
      "label": "Vent",
      "model": "Outlet",
      "output": 1,
      "power": 168.180744171,
      "enabled": 1,
      "current": 0.734311938,
      "voltage": 231.431150436,
      "powerfactor": 0.989632311,
      "relay": 1,
      "lock": 0
    }
  ],
  "status": "success"
}
```

Script is also compatible with Telegraf

Append to your telegraf.conf file (usually located in /etc/telegraf/telegraf.conf)
 
```sh
[[inputs.exec]]
# Command to execute.
commands = ["/root/ubnt-mpower-mfi/mpower.sh -u ubnt -p ubnt -i 192.168.1.10 -c emeter"]
# Command execution interval.
interval = "5s"
# Measurement name for InfluxDB (always use mFi- prefix for mPower mFi plug and hs110- for TpLink HS110 Smart Plug.
name_override = "mFi-HomeOffice"
# Do not change this.
data_format = "json"

```
If you have multiple smart plugs, just append same snippet again with different ip address and name_override variable.
Use Grafana mFi mPower & TP-Link HS110.json file and import it into your Grafana
