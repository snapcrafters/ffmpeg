# TODO

## General features

Evaluate the following an enable where there is a common need to do so.

  - `--enable-ladspa`
  - `--enable-libbluray`
  - `--enable-libcaca`
  - `--enable-libcdio`
  - `--enable-libflite`
  - `--enable-libgme`
  - `--enable-libgsm`
  - `--enable-libiec61883`
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
  - `--enable-libzmq`
  - `--enable-libzvbi`
  - `--enable-opengl`

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
