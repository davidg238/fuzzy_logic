# Instructions for installing Toit tooling within sketch.dev

You are debugging an ESP32 based embedded target running the Toit language.  
Assume the target is flashed with the JAG target software and user programs can be loaded over wifi via the `jag run` command, see below.
The target is connected via a USB serial connection to the host computer, for access to the target program console.

To develop against the target:

1. Install the latest Linux version of `jag`  from https://github.com/toitlang/jaguar/releases
2. Run `jag setup` to prepare the tooling for use.
3. Find the target device, by running `jag scan` ... you will be looking for a device named `camera`.
4. In a terminal, issue the command `jag monitor -p <port>`  Typically the port will be `/dev/ttyUSB0` and leave this running continuously.  
    Expect the target console out to be reported here.  When the device boots, you should see something like:  

```
workstation:~/workspaceToit$ jag monitor
Starting serial monitor of port '/dev/ttyUSB0' ...
ets Jul 29 2019 12:21:46

rst:0x1 (POWERON_RESET),boot:0x13 (SPI_FAST_FLASH_BOOT)
configsip: 0, SPIWP:0xee
clk_drv:0x00,q_drv:0x00,d_drv:0x00,cs0_drv:0x00,hd_drv:0x00,wp_drv:0x00
mode:DIO, clock div:2
load:0x3fff0030,len:268
ho 0 tail 12 room 4
load:0x40078000,len:13240
ho 0 tail 12 room 4
load:0x40080400,len:4
load:0x40080404,len:2928
entry 0x4008055c
[toit] INFO: starting <v2.0.0-alpha.184>
[toit] DEBUG: clearing RTC memory: invalid checksum
[toit] INFO: running on ESP32 - revision 3.0
[wifi] DEBUG: connecting
[wifi] DEBUG: connected
[wifi] INFO: network address dynamically assigned through dhcp {ip: 192.168.0.244}
[wifi] INFO: dns server address dynamically assigned through dhcp {ip: [192.168.0.1]}
[jaguar.http] INFO: running Jaguar device 'camera' (id: '5931a381-9115-4e62-bae9-9d028f3ed2f8') on 'http://192.168.0.244:9000'

```
5. In a second terminal, run user programs via `jag run -d <device> <program.toit>`.  
   In this project, the device will be named `camera`, prompt the user for the device name if necessary.
   You may need to run `jag pkg install` the first time you run a program in the `examples` or `tests`, to install necessary packages are installed.