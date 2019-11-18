#!/bin/bash

OSK="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
VMDIR=$PWD
OVMF=$VMDIR/firmware

[[ -z "$MEM" ]] && {
	MEM="4G"
}

[[ -z "$CPUS" ]] && {
	CPUS=4
}

echo "Hi $0 $1 $2"

if [ "$1" == "install" ]; then
  echo hi;

  qemu-system-x86_64 \
    -enable-kvm \
    -m $MEM \
    -machine q35,accel=kvm \
    -smp $CPUS \
    -cpu Penryn,vendor=GenuineIntel,kvm=on,+sse3,+sse4.2,+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe,+invtsc \
    -device isa-applesmc,osk="$OSK" \
    -smbios type=2 \
    -drive if=pflash,format=raw,readonly,file="$OVMF/OVMF_CODE.fd" \
    -drive if=pflash,format=raw,file="$OVMF/OVMF_VARS-1024x768.fd" \
    -vga qxl \
    -usb -device usb-tablet,bus=usb-bus.0 -device usb-kbd,bus=usb-bus.0 \
    -device e1000-82545em,netdev=net0,id=net0,mac=52:54:00:0e:0d:20 \
    -netdev user,id=net0,net=192.168.76.0/24,dhcpstart=192.168.76.9,hostfwd=tcp::22-:22 \
    -device ich9-ahci,id=sata \
    -drive id=ESP,if=none,format=qcow2,file=ESP.qcow2 \
    -device ide-hd,bus=sata.2,drive=ESP \
    -drive id=InstallMedia,format=raw,if=none,file=BaseSystem.img \
    -device ide-hd,bus=sata.3,drive=InstallMedia \
    -drive id=SystemDisk,if=none,file="/macOS.img" \
    -device ide-hd,bus=sata.4,drive=SystemDisk \
    -monitor telnet::45454,server,nowait \
    -nographic -vnc 0.0.0.0:0 -k $KEYBOARD
  exit;
fi

qemu-system-x86_64 \
    -enable-kvm \
    -m $MEM \
    -machine q35,accel=kvm \
    -smp $CPUS \
    -cpu Penryn,vendor=GenuineIntel,kvm=on,+sse3,+sse4.2,+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe,+invtsc \
    -device isa-applesmc,osk="$OSK" \
    -smbios type=2 \
    -drive if=pflash,format=raw,readonly,file="$OVMF/OVMF_CODE.fd" \
    -drive if=pflash,format=raw,file="$OVMF/OVMF_VARS-1024x768.fd" \
    -vga qxl \
    -usb -device usb-tablet,bus=usb-bus.0 -device usb-kbd,bus=usb-bus.0 \
    -device e1000-82545em,netdev=net0,id=net0,mac=52:54:00:0e:0d:20 \
    -netdev user,id=net0,net=192.168.76.0/24,dhcpstart=192.168.76.9,hostfwd=tcp::22-:22 \
    -device ich9-ahci,id=sata \
    -drive id=ESP,if=none,format=qcow2,file=ESP.qcow2 \
    -device ide-hd,bus=sata.2,drive=ESP \
    -drive id=SystemDisk,if=none,file="/macOS.img" \
    -device ide-hd,bus=sata.4,drive=SystemDisk \
    -monitor telnet::45454,server,nowait \
    -daemonize -vnc 0.0.0.0:0 -k $KEYBOARD

while ! nc -z 127.0.0.1 45454 ; do sleep 1 ; done

echo sending ret
end=$((SECONDS+30))

while [ $SECONDS -lt $end ] && nc -z 127.0.0.1 45454 && ! sshpass -p 'macos' ssh -q -o "StrictHostKeyChecking no" -o ConnectTimeout=1 macos@localhost -p 22 exit; do
    (echo "sendkey ret") | nc 127.0.0.1 45454 &> /dev/null;
    sleep 2;
done

echo done and ready
nc 127.0.0.1 45454
