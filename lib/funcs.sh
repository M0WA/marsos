#!/bin/bash

function download_and_verify() {
  URL=$1
  LOCALFILE=$2

  if [ "${FORCEREBUILD}" == "1" ]; then
    rm -rf "${LOCALFILE}" "${LOCALFILE}.sig"
  fi

  if [ ! -f "${LOCALFILE}" ]; then
    wget -4 -nv -O "${LOCALFILE}" ${URL}
  fi

  if [ ! -f "${LOCALFILE}.sig" ]; then
    wget -4 -nv -O "${LOCALFILE}.sig" ${URL}.sig || echo
  fi

  #TODO: check gpg signature
  #      see https://www.gnupg.org/faq/gnupg-faq.html#how_do_i_verify_signed_packages
}

export -f download_and_verify