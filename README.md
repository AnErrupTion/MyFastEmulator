<h1 align="center">
  <img src=".github/logo.png" alt="MyFastEmulator" />
  <br />
  MyFastEmulator
</h1>

<p align="center"><b>Easily manage your QEMU virtual machines.</b></p>
<div align="center"><img src=".github/screenshot.png" alt="MyFastEmulator Screenshot" /></div>
<p align="center">Made with 💝 for <img src="https://raw.githubusercontent.com/anythingcodes/slack-emoji-for-techies/gh-pages/emoji/tux.png" align="top" width="24" /></p>

## Introduction

MyFastEmulator is a fork of the <a href="https://github.com/wimpysworld/quickemu">Quickemu</a> project which aims to be a more complete and user-friendly version than Quickemu. But overall, it allows you to easily manage your QEMU virtual machines without any hassle. Each
virtual machine configuration is requiring minimal but very useful configuration, such as total CPU cores, emulated cpu, RAM, and even more. The
main objective of the project is to enable quick testing of desktop Linux
distributions AND Windows operating systems where the virtual machines can be stored anywhere, such as
external USB storage.

MyFastEmulator is faster than its competitors, for a few reasons. First, it uses emulation rather than pure virtualization. This allows, for example, to use a CPU NOT matching the host one. This also allows better VM performance and less CPU usage since it won't directly use the host CPU. Second, it's very minimal compareed to virt-manager, for example. It requires very minimal configuration and doesn't have too much features. And lastly, because it uses KVM as the main accelerator. VMware just can't use KVM, while VirtualBox "sort of can" use it as an option (however, KVM on Windows isn't real KVM as we all know). virt-manager, on the other hand, uses KVM. But it's not as fast as MyFastEmulator. MyFastEmulator is also a frontend to the fully
accelerated [qemu-virgil](https://snapcraft.io/qemu-virgil). See the video
where wimpysworld explains some of his motivations for creating the original script :

[![Replace VirtualBox with Bash & QEMU](https://img.youtube.com/vi/AOTYWEgw0hI/0.jpg)](https://www.youtube.com/watch?v=AOTYWEgw0hI)

## Installation

Clone this repository:

```
git clone https://github.com/AnErrupTion/MyFastEmulator.git
```

Install the `qemu-virgil` snap. You can find details about how to install snapd
and `qemu-virgil`  on the [Snap Store page for qemu-virgil](https://snapcraft.io/qemu-virgil).
Note that this will use the bleeding edge version of qemu-virgil (required for the last command).

```bash
snap install qemu-virgil --edge
snap connect qemu-virgil:kvm
snap connect qemu-virgil:raw-usb
snap connect qemu-virgil:removable-media
```

## Usage

## FOR WINDOWS

~~The Windows installer won't recognize your virtual HDD, which is (kind of) normal. To make it detect it, you'll have to install the VirtIO SCSI drivers. To do that, follow the steps below.~~

 ~~* Download the complete [VirtIO drivers ISO file](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso), rename it to whatever you want (example : `virtio_drivers.iso`) then place it wherever you want (example : in the directory where there is MyFastEmulator).~~

 ~~* Edit your configuration file, and add this line : `driver_iso="virtio_drivers.iso"`. Save the file, and close it.~~

 ~~* Boot the VM into the Windows installer of your choice (7, 10, etc...). Now, where the partitions should appear, click `Load driver`. In the following message box, click `Browse`, then go to the mounted ISO file, then go to `amd64`, then click on the folder that matches the Windows version you're installing (for example, win7). Now, load the driver, and the partition should appear!~~
 The bug above has been fixed, thus it is not needed anymore to manually add the VirtIO drivers (it now uses AHCI, which si detected by both Windows and Linux distros).

## FOR LINUX

  * Download an ISO image of a Linux distribution
  * Create a VM configuration file, for example `your_configuration_file.conf`

```
iso="focal-desktop-amd64.iso"
disk_img="focal-desktop-amd64.qcow2
disk=60G
```
(These are only a few options of MyFastEmulator. To see the full list of options, see the `example.conf` file.</a>.)

  * Use `myfastemu` to start the virtual machine:

```
./myfastemu -vm your_configuration_file.conf
```

Which will output something like this:

<div align="center"><img src=".github/screenshot2.png" alt="MyFastEmulator Console Screenshot" /></div>

Here are the full usage instructions:

```
Usage
  ./myfastemu -vm your_configuration_file.conf

You can also pass optional parameters
  --snapshot apply <tag>  : Apply/restore a snapshot.
  --snapshot create <tag> : Create a snapshot.
  --snapshot delete <tag> : Delete a snapshot.
  --snapshot info         : Show disk/snapshot info.
```

## TODO

  - [x] Make display configuration more robust
  - [x] Improve stdout presentation
  - [x] Make disk image size configurable
  - [x] Improve snapshot management
  - [ ] Make an option to create a desktop launcher (shortcut) for a VM
  - [x] Add support for Virgil3D
  - [x] Add support for GL
  - [x] Get QEMU `-audiodev` working for audio input
  - [x] Add Windows support
  - [x] Improve performance
  - [x] Add USB pass-through support
  - [ ] Improve disk management
