# The FFmpeg snap
[![Build Status](https://travis-ci.com/snapcrafters/ffmpeg.svg?branch=master)](https://travis-ci.com/snapcrafters/ffmpeg)
[![Get it from the Snap Store](https://snapcraft.io/static/images/badges/en/snap-store-black.svg)](https://snapcraft.io/ffmpeg)

### Review FFmpeg build options

Most `--enable-*` flags used in the snap of FFmpeg are consistent with what's
used in the .deb of FFmpeg in Ubuntu. Determine which of the following are
generally useful and enable them:

  * `--enable-ladspa`
  * `--enable-libaom` (core20)
  * `--enable-libjack`
  * `--enable-libmysofa`
  * `--enable-libvidstab` (core20)
  * `--enable-lv2`
  * `--enable-libiec61883` (FTBFS on core18)
  * `--enable-frei0r`

### Raspberry Pi

Add support for the Raspberry Pi in the `armhf` and `arm64` builds.

[libraspberrypi-dev] will need including in the build process but doesn't need
to to be primed. This package adds the headers that make it possible to enable
`--enable-mmal` (Broadcom Multi-Media Abstraction Layer) and `--enable-omx-rpi`.

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

## Reference

* [debian/rules · debian/master · Debian Multimedia Team / ffmpeg · GitLab](https://salsa.debian.org/multimedia-team/ffmpeg/blob/debian/master/debian/rules)