<h1 align="center">
  <img src=".github/logo.png" alt="MyFastEmulator v2" />
  <br />
  MyFastEmulator v3
</h1>

<p align="center"><b>Frontend for QEMU, with nice features.</b></p>
<div align="center"><img src=".github/screenshot.png" alt="MyFastEmulator v3 Screenshot" /></div>
<p align="center">Made with 💝 for <img src="https://raw.githubusercontent.com/anythingcodes/slack-emoji-for-techies/gh-pages/emoji/tux.png" align="top" width="24" /></p>

## Introduction

MyFastEmulator v3 is a simple yet powerful QEMU frontend made for portability and easability. You can store your virtual machines on a USB storage device for example, and use them whenever you want to. Every virtual machine can also be customized a lot, which makes MyFastEmulator one of the few good QEMU frontends out there.

MyFastEmulator v3 is very lightweight since it's a bash script, so it doesn't use a lot of resources on your machine, allowing for even better virtual machine performance. MyFastEmulator also uses carefully selected QEMU flags along with your configurated ones for more snappiness overall. You can also watch Wimpy's World video where he makes 

[![Replace VirtualBox with Bash & QEMU](https://img.youtube.com/vi/AOTYWEgw0hI/0.jpg)](https://www.youtube.com/watch?v=AOTYWEgw0hI)

## Installing QEMU

You must first install QEMU v5.2.0 if you haven't done it already. For Ubuntu and its derivatives, you may want to use the Compile QEMU file in the repository (since QEMU in the Ubuntu repos is for some reason a dummy package).

## Getting started

You need to clone this repository in order to get started :

```
git clone --single-branch --branch=mfe-v3 https://github.com/AnErrupTion/MyFastEmulator.git
```

## Usage

  * Download an ISO image of the operating system of your choice
  * Create a virtual machine configuration file, for example `windows.conf`

```
iso="Windows10.iso"
disk_img="Windows10.qcow2"
disk=60G
```
(These are only a few options of MyFastEmulator v3. To see the full list of options, see the `example.conf` file.)

You can also use our config creator, which makes this process much easier :
```
./config-creator
```

  * Use `myfastemu` to start the virtual machine :

```
./myfastemu -vm your_configuration_file.conf
```

  * A Desktop shortcut can be created (in ~/.local/share/applications):
```
./myfastemu -vm your_configuration_file.conf -shortcut
```

  * NOTE : If you have an error where it cannot find the virtual HDD or that you haven't specified an ISO image (with desktop shortcut, at the startup of the VM) then you need to **add the full path of the virtual disk and ISO image in the configuration file**.

When starting the virtual machine, you should have a console that looks like this :

<div align="center"><img src=".github/screenshot2.png" alt="MyFastEmulator v3 Console Screenshot" /></div>

Here are the full usage instructions :

```
Usage
  ./myfastemu -vm your_configuration_file.conf

You can also pass optional parameters
  --delete                : Delete the desktop shortcut.
  --shortcut              : Create a desktop shortcut.
  --snapshot apply <tag>  : Apply/restore a snapshot.
  --snapshot create <tag> : Create a snapshot.
  --snapshot delete <tag> : Delete a snapshot.
  --snapshot info         : Show disk/snapshot info.
```

## TODO

There's nothing here yet!
