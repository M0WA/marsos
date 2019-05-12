#!/bin/bash

function download_and_verify() {
  URL=$1
  LOCALFILE=$2

  if [ ! -f ${LOCALFILE} ]; then
    wget -4 -O ${LOCALFILE}     ${URL}
    wget -4 -O ${LOCALFILE}.sig ${URL}.sig || echo
  fi

  #TODO: check gpg signature
  #      see https://www.gnupg.org/faq/gnupg-faq.html#how_do_i_verify_signed_packages
}

export -f download_and_verify