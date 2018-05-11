# TODO

## General features

Evaluate the following an enable where there is a common need to do so.

  - `--enable-gnutls`
  - `--enable-ladspa`
  - `--enable-libbluray`
  - `--enable-libcaca`
  - `--enable-libcdio`
  - `--enable-libflite`
  - `--enable-libgme`
  - `--enable-libgsm`
  - `--enable-libiec61883`
  - `--enable-libopencore_amrnb`
  - `--enable-libopencore_amrwb`
  - `--enable-libopencv`
  - `--enable-libopenjpeg`
  - `--enable-libopenmpt`
  - `--enable-librubberband`
  - `--enable-libsnappy`
  - `--enable-libsoxr`
  - `--enable-libssh`
  - `--enable-libtesseract`
  - `--enable-librsvg`
  - `--enable-libvo_amrwbenc`
  - `--enable-libwavpack`
  - `--enable-libwebp`
  - `--enable-libxml2`
  - `--enable-libxvid`
  - `--enable-libzmq`
  - `--enable-libzvbi`
  - `--enable-openal`
  - `--enable-opengl`
  - `--enable-sdl2`

## Raspberry Pi

Add support for the Raspberry Pi in the `armhf` builds.

[libraspberrypi-dev](https://archive.raspberrypi.org/debian/pool/main/r/raspberrypi-firmware/libraspberrypi-dev_1.20180417-1_armhf.deb)
will need dumping for the build process but doesn't need to to be
primed. This package adds the headers that make it possible to enable
`--enable-mmal` (Broadcom Multi-Media Abstraction Layer) and
`--enable-omx-rpi`.

The Raspberry Pi specific build options have been used in custom builds
before.

```
# Raspberry Pi specific optimizations
ifeq ($(DEB_HOST_ARCH),armhf)
  CONFIG += --arch=arm
  #CONFIG += --cpu=arm1176jzf-s
  CONFIG += --disable-armv5te
  CONFIG += --disable-neon
  #CONFIG += --enable-armv6t2
  #CONFIG += --enable-armv6
  #CONFIG += --enable-vfp
  CONFIG += --enable-hardcoded-tables
  CONFIG += --enable-mmal
  CONFIG += --enable-omx-rpi
  CONFIG += --disable-decoder=mpeg_xvmc
  CONFIG += --disable-vaapi
  CONFIG += --disable-vdpau
  CONFIG += --disable-runtime-cpudetect
  CONFIG += --disable-debug
  CONFIG += --extra-cflags="-mno-apcs-stack-check -mstructure-size-boundary=32 -mno-sched-prolog"
else
  CONFIG += --enable-omx
endif
```

# Confinement

The snap works in devmode or classic confinement, but not when strictly
confined.

## stdout

This is seen on stdout when trying to use `nvenc` when confined.

```
[nvenc @ 0x1460380] Cannot init CUDA
Error initializing output stream 0:0 -- Error while opening encoder for output stream #0:0 - maybe incorrect parameters such as bit_rate, rate, width or height
```

## syslog

This is seen in syslog when trying to use `nvenc` when confined.

```
May  2 18:26:10 skull kernel: [ 7984.861530] audit: type=1400 audit(1525281970.544:585): apparmor="DENIED" operation="open" profile="snap.ffmpeg.ffmpeg" name="/proc/sys/vm/mmap_min_addr" pid=25709 comm="ffmpeg" requested_mask="r" denied_mask="r" fsuid=1000 ouid=0
May  2 18:26:10 skull kernel: [ 7984.861615] audit: type=1400 audit(1525281970.544:586): apparmor="DENIED" operation="open" profile="snap.ffmpeg.ffmpeg" name="/proc/sys/vm/mmap_min_addr" pid=25709 comm="ffmpeg" requested_mask="r" denied_mask="r" fsuid=1000 ouid=0
May  2 18:26:10 skull kernel: [ 7984.861900] audit: type=1400 audit(1525281970.544:587): apparmor="DENIED" operation="open" profile="snap.ffmpeg.ffmpeg" name="/proc/devices" pid=25709 comm="ffmpeg" requested_mask="r" denied_mask="r" fsuid=1000 ouid=0
May  2 18:26:10 skull kernel: [ 7984.862195] audit: type=1400 audit(1525281970.544:588): apparmor="DENIED" operation="open" profile="snap.ffmpeg.ffmpeg" name="/sys/devices/system/memory/block_size_bytes" pid=25709 comm="ffmpeg" requested_mask="r" denied_mask="r" fsuid=1000 ouid=0
May  2 18:26:10 skull kernel: [ 7984.903014] audit: type=1400 audit(1525281970.584:589): apparmor="DENIED" operation="bind" profile="snap.ffmpeg.ffmpeg" pid=25709 comm="ffmpeg" family="unix" sock_type="seqpacket" protocol=0 requested_mask="bind" denied_mask="bind" addr="@637564612D75766D66642D343032363533313833362D323537303900"
May  2 18:26:10 skull kernel: [ 7984.943833] audit: type=1400 audit(1525281970.594:590): apparmor="DENIED" operation="listen" profile="snap.ffmpeg.ffmpeg" pid=12034 comm="ffmpeg" family="unix" sock_type="seqpacket" protocol=0 requested_mask="listen" denied_mask="listen" addr="@637564612D75766D66642D343032363533313833362D313230333400"
```

The denials above can be temporarily permitted by adding the following
to `/var/lib/snapd/apparmor/profiles/snap.ffmpeg.ffmpeg`:

```
@{PROC}/sys/vm/mmap_min_addr r,
@{PROC}/devices r,
/sys/devices/system/memory/block_size_bytes r,
unix (bind,listen) type=seqpacket addr="@cuda-uvmfd-[0-9a-f]*",
```

And then reload the AppArmor policy with `sudo apparmor_parser -r
/var/lib/snapd/apparmor/profiles/snap.ffmpeg.ffmpeg`.
