#!/usr/bin/env bash

function disk_delete() {
  if [ -e "${disk_img}" ]; then
    rm "${disk_img}"
    echo " - SUCCESS! Deleted ${disk_img}"
  else
    echo " - ERROR! ${disk_img} not found. Skipping disk deletion."
  fi
}

function snapshot_apply() {
	local snapshot_tag="${1}"
  	if [ -z "${snapshot_tag}" ]; then
    	echo " - ERROR! No snapshot tag provided."
    	exit
  	fi

  	if [ -e "${disk_img}" ]; then
    	${QEMU_IMG} snapshot -q -a "${snapshot_tag}" "${disk_img}"
    	if [ $? -eq 0 ]; then
      		echo " - SUCCESS! Applied snapshot ${snapshot_tag} to ${disk_img}."
    	else
      		echo " - ERROR! Failed to apply snapshot ${snapshot_id} to ${disk_img}."
    	fi
  	else
    	echo " - ERROR! ${disk_img} not found. Doing nothing."
    fi
}

function snapshot_create() {
	local snapshot_tag="${1}"
  	if [ -z "${snapshot_tag}" ]; then
    	echo " - ERROR! No snapshot tag provided."
    	exit
  	fi

  	if [ -e "${disk_img}" ]; then
  		${QEMU_IMG} snapshot -q -c "${snapshot_tag}" "${disk_img}"
  		if [ $? -eq 0 ]; then
      		echo " - SUCCESS! Created snapshot ${snapshot_tag} of ${disk_img}."
    	else
      		echo " - ERROR! Failed to create snapshot ${snapshot_id} of ${disk_img}."
    	fi
    else
    	echo " - ERROR! ${disk_img} not found. Doing nothing."
    fi
}

function snapshot_delete() {
	local snapshot_tag="${1}"
  	if [ -z "${snapshot_tag}" ]; then
    	echo " - ERROR! No snapshot tag provided."
    	exit
  	fi

  	if [ -e "${disk_img}" ]; then
  		${QEMU_IMG} snapshot -q -d "${snapshot_tag}" "${disk_img}"
  		if [ $? -eq 0 ]; then
      		echo " - SUCCESS! Deleted snapshot ${snapshot_tag} of ${disk_img}."
    	else
      		echo " - ERROR! Failed to delete snapshot ${snapshot_id} of ${disk_img}."
    	fi
    else
    	echo " - ERROR! ${disk_img} not found. Doing nothing."
    fi
}

function snapshot_info() {
	if [ -e "${disk_img}" ]; then
		${QEMU_IMG} info "${disk_img}"
	fi
}

function get_port() {
    local PORT_START=22220
    local PORT_RANGE=9
    while true; do
        local CANDIDATE=$[${PORT_START} + (${RANDOM} % ${PORT_RANGE})]
        (echo "" >/dev/tcp/127.0.0.1/${CANDIDATE}) >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "${CANDIDATE}"
            break
        fi
    done
}

function vm_boot() {
  local VMNAME=$(basename ${VM} .conf)
  local VMDIR=$(dirname ${disk_img})
  local BIOS=""
  local VIRGL="on"
  local UI="gtk"
  local QEMU_VER=$(${QEMU} -version | head -n1 | cut -d' ' -f4 | cut -d'(' -f1)
  echo " - Initializing \"${VM}\"'s settings."
  echo " - QEMU:     ${QEMU} v${QEMU_VER}"

  local disk_curr_size=$(stat -c%s "${disk_img}")
  if [ -z "${disk}" ]; then
  	echo " - Disk size not found, setting default value."
    disk="64G"
  fi

  if [ ! -z "${efi_bios}" ]; then
  	if [ "${efi_bios}" -eq 1 ]; then
  		if [ -e /snap/qemu-virgil/current/usr/share/qemu/edk2-x86_64-code.fd ] ; then
      		if [ ! -e ${VMDIR}/${VMNAME}-vars.fd ]; then
      			cp /snap/qemu-virgil/current/usr/share/qemu/edk2-i386-vars.fd ${VMDIR}/${VMNAME}-vars.fd
      		fi
      		BIOS="-drive if=pflash,format=raw,readonly,file=/snap/qemu-virgil/current/usr/share/qemu/edk2-x86_64-code.fd -drive if=pflash,format=raw,file=${VMDIR}/${VMNAME}-vars.fd"
    	else
      		echo " - EFI:      Booting requested but no EFI firmware found."
      		echo "             Booting from Legacy BIOS."
    	fi
    	echo " - BIOS:     EFI"
  	else
  		echo " - BIOS:     Legacy"
  	fi
  else
    echo " - BIOS:     Legacy"
  fi

  if [ ! -f "${disk_img}" ]; then
    # If there is no disk image, create a new image.
    echo " - Creating a new image."
    touch "${disk_img}"
    ${QEMU_IMG} create -q -f qcow2 "${disk_img}" "${disk}"
    echo "             - Just created, booting from ${iso}."
    if [ $? -ne 0 ]; then
      echo " - ERROR! Failed to create ${disk_img} of ${disk}. Stopping here."
      exit 1
    fi
    echo " - ISO:      ${iso}"
  else
  	# Check there isn't already a process attached to the disk image.
  	QEMU_LOCK_TEST=$(${QEMU_IMG} info ${disk_img} 2>/dev/null)
  	if [ $? -ne 0 ]; then
    	echo "             - Failed to get \"write\" lock. Is another process using the disk?"
    	exit 1
  	fi

  	local disk_curr_size=$(stat -c%s "${disk_img}")
  	if [ ! ${disk_curr_size} -le ${DISK_MIN_SIZE} ]; then
  		# If there is a disk image AND there is an install on it, do not boot from the iso
     	iso=""
  	fi
  fi
  if [ -e ${disk_img_snapshot} ]; then
    echo " - Snapshot: ${disk_img_snapshot}"
  fi
  echo " - Disk:     ${disk_img} (${disk})"

  # Has the status quo been requested?
  if [ "${status_quo}" -eq 1 ] && [ -z "${iso}" ]; then
  	STATUSQUO="-snapshot"
    echo "              - Existing disk state will be preserved, no changes to the disk/snapshot will be committed."
  fi

  local cores="1"
  local allcores=$(nproc --all)
  if [ ${allcores} -ge 8 ]; then
    cores="4"
  elif [ ${allcores} -ge 4 ]; then
    cores="2"
  fi

  if [ ! -z "${total_cores}" ]; then
  	echo " - CPU cores choosed by user."
    cores="${total_cores}"
  fi
  echo " - CPU Cores: ${cores} Core(s)"

  local acpu="host"
  if [ ! -z "${emulated_cpu}" ]; then
  	echo " - Emulated CPU choosed by user."
    acpu="${emulated_cpu}"
  fi
  echo " - Emulated CPU: ${acpu}"

  local ram="2G"
  local allram=$(free --mega -h | grep Mem | cut -d':' -f2 | cut -d'G' -f1 | sed 's/ //g')
  if [ ${allram} -ge 64 ]; then
    ram="4G"
  elif [ ${allram} -ge 16 ]; then
    ram="3G"
  fi

  if [ ! -z "${ram_gb}" ]; then
  	echo " - RAM choosed by user."
    ram="${ram_gb}"
  fi
  echo " - RAM:      ${ram}"

  local display=""

  # Determine what display to use
  if [ ! -z "${vga_adapter}" ]; then
  	echo " - VGA adapter choosed by user."
    display="-display ${UI} -vga ${vga_adapter}"
  else
  	display="-display ${UI} -vga virtio"
  fi

  if [ ! -z "${guest_ui}" ]; then
  	echo " - Guest UI choosed by user."
    UI="${guest_ui}"
  fi
  echo " - UI:       ${UI}"
  if [ ! -z "${guest_virgl}" ]; then
  	echo " - Guest VirGL choosed by user."
    VIRGL="${guest_virgl}"
  fi
  echo " - VIRGL:    ${VIRGL}"

  local xres=1152
  local yres=648
  if [ "${XDG_SESSION_TYPE}" == "x11" ]; then
    local LOWEST_WIDTH=$(xrandr --listmonitors | grep -v Monitors | cut -d' ' -f4 | cut -d'/' -f1 | sort | head -n1)
    if [ ${LOWEST_WIDTH} -ge 3840 ]; then
      xres=3200
      yres=1800
    elif [ ${LOWEST_WIDTH} -ge 2560 ]; then
      xres=2048
      yres=1152
    elif [ ${LOWEST_WIDTH} -ge 1920 ]; then
      xres=1664
      yres=936
    elif [ ${LOWEST_WIDTH} -ge 1280 ]; then
      xres=1152
      yres=648
    fi
  fi

  if [ ! -z "${guest_xres}" ]; then
  	echo " - Guest's width resolution choosed by user."
    xres="${guest_xres}"
  fi
  if [ ! -z "${guest_yres}" ]; then
  	echo " - Guest's height resolution choosed by user."
    yres="${guest_yres}"
  fi
  echo " - Display:  ${xres}x${yres}"


  local NET=""
  # If smbd is available, export $HOME to the guest via samba
  if [ -e /snap/qemu-virgil/current/usr/sbin/smbd ]; then
      NET=",smb=${HOME}"
  fi

  if [ -n "${NET}" ]; then
    echo " - smbd:     ${HOME} will be exported to the guest via smb://10.0.2.4/qemu"
  else
    echo " - smbd:     ${HOME} will not be exported to the guest. 'smbd' not found."
  fi

  # Find a free port to expose ssh to the guest
  local PORT=$(get_port)
  if [ -n "${PORT}" ]; then
    NET="${NET},hostfwd=tcp::${PORT}-:22"
    echo " - ssh:      ${PORT}/tcp is connected. Login via 'ssh user@localhost -p ${PORT}'"
  else
    echo " - ssh:      All ports for exposing ssh have been exhausted."
  fi

  # Boot the iso image
  echo " - Launching \"${VM}\" with requested settings."
  ${QEMU} -name ${VMNAME},process=${VMNAME} \
    ${BIOS} \
    -cdrom "${iso}" \
    -drive "file=${disk_img},format=qcow2,if=virtio,aio=native,cache.direct=on" \
    -drive "file=virtio_drivers.iso,index=0,media=cdrom" \
    -enable-kvm \
    -machine q35,accel=kvm \
    -cpu ${acpu},kvm=on \
    -m ${ram} \
    -smp cores=${cores} \
    -net nic,model=virtio \
    -net user"${NET}" \
    -rtc base=localtime,clock=host \
    -serial mon:stdio \
    -audiodev pa,id=pa,server=unix:$XDG_RUNTIME_DIR/pulse/native,out.stream-name=${LAUNCHER}-${VMNAME},in.stream-name=${LAUNCHER}-${VMNAME} \
    -device intel-hda -device hda-duplex,audiodev=pa \
    -usb -device usb-kbd -device usb-tablet \
    -object rng-random,id=rng0,filename=/dev/urandom \
    -device virtio-rng-pci,rng=rng0 \
    ${display} ${STATUSQUO} \
    "$@"
}

function usage() {
  echo
  echo "Usage"
  echo "  ${LAUNCHER} --vm CONFIG_FILE.conf"
  echo
  echo "You can also pass optional parameters"
  echo "  --delete   : Delete the disk image."
  echo "  --snapshot apply <tag>  : Apply/restore a snapshot."
  echo "  --snapshot create <tag> : Create a snapshot."
  echo "  --snapshot delete <tag> : Delete a snapshot."
  echo "  --snapshot info         : Show disk/snapshot info."
  exit 1
}

DELETE=0
readonly QEMU="/snap/bin/qemu-virgil"
readonly QEMU_IMG="/snap/bin/qemu-virgil.qemu-img"
readonly LAUNCHER=$(basename $0)
readonly DISK_MIN_SIZE=$((197632 * 8))
SNAPSHOT_ACTION=""
SNAPSHOT_TAG=""
SNAPSHOT=0
STATUSQUO=""
VM=""

while [ $# -gt 0 ]; do
  case "${1}" in
    -delete|--delete)
      DELETE=1
      shift;;
    -snapshot|--snapshot)
      SNAPSHOT_ACTION="${2}"
      if [ -z "${SNAPSHOT_ACTION}" ]; then
        echo " - ERROR! No snapshot action provided."
        exit 1
      fi
      shift
      SNAPSHOT_TAG="${2}"
      if [ -z "${SNAPSHOT_TAG}" ] && [ "${SNAPSHOT_ACTION}" != "info" ]; then
        echo " - ERROR! No snapshot tag provided."
        exit 1
      fi
      SNAPSHOT=1
      shift
      shift;;
    -vm|--vm)
      VM="$2"
      shift
      shift;;
    -h|--h|-help|--help)
      usage;;
    *)
    echo " - ERROR! \"${1}\" is not a supported parameter."
    usage;;
  esac
done

# Check we have qemu-virgil available
if [ ! -e "${QEMU}" ] && [ ! -e "${QEMU_IMG}" ]; then
  echo " - ERROR! qemu-virgil not found. Please install the qemu-virgil snap."
  echo "          https://snapcraft.io/qemu-virgil"
  exit 1
fi

if [ -n "${VM}" ] || [ -e "${VM}" ]; then
  source "${VM}"
  if [ -z "${disk_img}" ]; then
    echo " - ERROR! No disk_img defined."
    exit 1
  fi 
else
  echo " - ERROR! Virtual machine configuration not found."
  usage
fi

if [ ${DELETE} -eq 1 ]; then
  disk_delete
  exit
fi

if [ ${SNAPSHOT} -eq 1 ]; then
  if [ -n "${SNAPSHOT_ACTION}" ]; then
    case ${SNAPSHOT_ACTION} in
    	apply)
      		snapshot_apply "${SNAPSHOT_TAG}"
      		snapshot_info
      		exit;;
    	create)
      		snapshot_create "${SNAPSHOT_TAG}"
      		snapshot_info
      		exit;;
    	delete)
      		snapshot_delete "${SNAPSHOT_TAG}"
      		snapshot_info
      		exit;;
    	info)
      		snapshot_info
      		exit;;
    	*)
    echo " - ERROR! \"${SNAPSHOT_ACTION}\" is not a supported snapshot action."
    usage;;
  	esac
  fi
fi

vm_boot