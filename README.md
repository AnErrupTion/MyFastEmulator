<h1 align="center">
  <img src=".github/logo.png" alt="Quickemu" />
  <br />
  MyFastEmulator
</h1>

<p align="center"><b>Simple shell script to "manage" Qemu virtual machines.</b></p>
<div align="center"><img src=".github/screenshot.png" alt="Quickemu Screenshot" /></div>
<p align="center">Made with 💝 for <img src="https://raw.githubusercontent.com/anythingcodes/slack-emoji-for-techies/gh-pages/emoji/tux.png" align="top" width="24" /></p>

## Introduction

MyFastEmulator is a fork of the <a href="https://github.com/wimpysworld/quickemu">Quickemu</a> which aims to be a more complete and user-friendly version than Quickemu. But overall, it's a very simple script to "manage" QEMU virtual machines. Each
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
snap connect qemu-virgil:removable-media
```

## Usage

## FOR WINDOWS

The Windows installer won't recognize your virtual HDD, which is (kind of) normal. To make it detect it, you'll have to install the VirtIO SCSI drivers. To do that, follow the steps below.

 * Download the complete [VirtIO drivers ISO file](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso), rename it to whatever you want (example : `virtio_drivers.iso`) then place it wherever you want (example : in the directory where there is MyFastEmulator).
 
 * Edit your configuration file, and add this line : `driver_iso="virtio_drivers.iso"`. Save the file, and close it.
 
 * Boot the VM into the Windows installer of your choice (7, 10, etc...). Now, where the partitions should appear, click `Load driver`. In the following message box, click `Browse`, then go to the mounted ISO file, then go to `amd64`, then click on the folder that matches the Windows version you're installing (for example, win7). Now, load the driver, and the partition should appear!

 * NOTE : After the installation, install the guest tools from the mounted CD to get better performance.
 * Windows 7 : Install the QEMU Guest Agent (can be found in `guest-agent`).
 * Windows 8 and newer : Install the VirtIO Guest Tools (can be found at the very bottom).
 * For all Windows starting from Windows 7 : Install the SPICE Guest Tools (can be found on the website `spice-space.org`).

## FOR LINUX

  * Download an ISO image of a Linux distribution
  * Create a VM configuration file, for example `your_configuration_file.conf`

```
iso="focal-desktop-amd64.iso"
disk_img="focal-desktop-amd64.qcow2
disk=60G
```
(These are only a few options of MyFastEmulator. To see the full list of options, go <a href="#">here</a>.)

  * Use `quickemu` to start the virtual machine:

```
./quickemu --vm your_configuration_file.conf
```

Which will output something like this:

```
Starting your_configuration_file.conf
 - QEMU:     /snap/bin/qemu-virgil v4.2.0
 - BIOS:     Legacy
 - Disk:     focal-desktop-amd64.qcow2 (64G)
 - ISO:      focal-desktop-amd64.iso
 - CPU:      4 Core(s)
 - RAM:      4G
 - UI:       gtk
 - VIRGL:    off
 - Display:  1664x936
 - smbd:     /home/USERNAME will be exported to the guest via smb://10.0.2.4/qemu
 - ssh:      22221/tcp is connected. Login via 'ssh user@localhost -p 22221'
```

Here are the full usage instructions:

```
Usage
  quickemu --vm your_configuration_file.conf

You can also pass optional parameters
  --delete                : Delete the disk image.
  --snapshot apply <tag>  : Apply/restore a snapshot.
  --snapshot create <tag> : Create a snapshot.
  --snapshot delete <tag> : Delete a snapshot.
  --snapshot info         : Show disk/snapshot info.
```

## TODO

  - [x] Make display configuration more robust
  - [x] Improve stdout presentation
  - [x] Make disk image optionally size configurable
  - [x] Improve snapshot management
  - [ ] Create desktop launcher for a VM
  - [x] Add support for Virgil3D
  - [x] Add support for GL
  - [x] Get QEMU `-audiodev` working for audio input
  - [x] Add Windows support
  - [ ] Fix crazy mouse pointer on Windows
