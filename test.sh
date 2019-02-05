#!/usr/bin/env bash

SAMPLE_VIDEO="${HOME}/Videos/input.mp4"
TEST_LIBX264=0

function title() {
  TITLE="${1}"
  echo -e "\n## ${TITLE}\n"
}

function encode() {
  FFMPEG="${1}"
  VCODEC="${2}"
  PACKAGE="${3}"
  OUTPUT="${HOME}/test_${PACKAGE}_${VCODEC}.mp4"

  title "${FFMPEG} is encoding ${SAMPLE_VIDEO} using ${VCODEC}"
  if [[ ${VCODEC} = *"nvenc"* ]]; then
    # Do we have NVENC capable hardware?
    NVENC=$(nvidia-smi -q | grep Encoder | wc -l)
    if [ ${NVENC} -ge 1 ]; then
      /usr/bin/time --format=" - elapsed time: %e" ${FFMPEG} -hide_banner -loglevel error -y -i ${SAMPLE_VIDEO} -vcodec ${VCODEC} -acodec copy ${OUTPUT}
    else
      echo " - incompatible hardware skipping ${VCODEC} test."
    fi
  elif [[ ${VCODEC} = *"vaapi"* ]]; then
    # Do we have VA-API capable hardware?
    VAINFO=$(vainfo 2>/dev/null)
    VAAPI=$?
    if [ ${VAAPI} -eq 0 ]; then
      /usr/bin/time --format=" - elapsed time: %e" ${FFMPEG} -hide_banner -loglevel error -y -vaapi_device /dev/dri/renderD128 -i ${SAMPLE_VIDEO} -vf 'format=nv12,hwupload' -vcodec ${VCODEC} -acodec copy ${OUTPUT}
    else
      echo " - incompatible hardware skipping ${VCODEC} test."
    fi
  else
    /usr/bin/time --format=" - elapsed time: %e" ${FFMPEG} -hide_banner -loglevel error -y -i ${SAMPLE_VIDEO} -vcodec ${VCODEC} -acodec copy ${OUTPUT}
  fi
}

sudo apt install -y ffmpeg 2>/dev/null
sudo apt install -y vainfo 2>/dev/null

# Make sure the correct version of nvidia-smi is installed
for NV_VER in 390 396 410 415; do
  dpkg -s nvidia-driver-${NV_VER} &> /dev/null
  if [ $? -eq 0 ]; then
    echo "nvidia $NV_VER is installed"
    sudo apt install -y nvidia-utils-${NV_VER} 2>/dev/null
    break
  fi
done

if [ -f ffmpeg_4.1_amd64.snap ]; then
  sudo snap install ffmpeg_4.1_amd64.snap --dangerous
  sudo snap connect ffmpeg:camera
  sudo snap connect ffmpeg:hardware-observe
fi

for LOCATION in usr snap; do
  title "ffmpeg ${LOCATION} features"
  /${LOCATION}/bin/ffmpeg -hide_banner -hwaccels
  for FEATURE in encoders decoders filters; do
    echo ${FEATURE}:; /${LOCATION}/bin/ffmpeg -hide_banner -${FEATURE} | egrep -i "cuda|cuvid|mmal|npp|nvdec|nvenc|omx|vaapi|vdpau"
  done
done

# CPU Encode
for LOCATION in usr snap; do
  if [ ${TEST_LIBX264} -eq 1 ]; then
    encode /${LOCATION}/bin/ffmpeg libx264 ${LOCATION}
  fi
done

# NVENC/HEVC Encode
for LOCATION in usr snap; do
  encode /${LOCATION}/bin/ffmpeg h264_nvenc ${LOCATION}
  encode /${LOCATION}/bin/ffmpeg hevc_nvenc ${LOCATION}
done

# VA-API Encode
for LOCATION in usr snap; do
  encode /${LOCATION}/bin/ffmpeg h264_vaapi ${LOCATION}
done
