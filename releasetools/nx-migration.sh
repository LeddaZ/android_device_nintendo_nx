#!/bin/sh
#
# NX Android L4T Loader Migration Tool
# Copyright (c) Thomas Makin 2023
#
# This tool assists the Edify script in releasetools in migrating configurations
# from the old coreboot-based NX bootloader system to the new L4T-Loader bootloader
# system. This includes copying relevant config entries from the old ini and old
# uenv to the new unified hekate ini (used for hekate and uenv configuration).
#

NX_FILES=/mnt/vendor/hos_data
NX_SUBDIR=${NX_FILES}/switchroot/android

EMMC=0
UART_PORT=0

overlay_match(line) {
    for string in ${line//,/ }
    do
        echo "Parsed overlay ${string}"
        # test for overlays replaced by env vars
        case ${string} in
            *tegra210-icosa_emmc-overlay* ) EMMC=1 ;;
            *tegra210-UART-A-overlay* ) UART_PORT=1 ;;
            *tegra210-UART-B-overlay* ) UART_PORT=2 ;;
            *tegra210-UART-C-overlay* ) UART_PORT=3 ;;
            * ) OVERLAYS=${string},${OVERLAYS} ;;
        esac
        if [ -n ${OVERLAYS} ]; then
            echo "overlays=${OVERLAYS}" | rev | cut -c2- | rev >> ${NX_FILES}/bootloader/ini/android.ini
        fi
    done
}

iniCopy() {
    printf "Step 1/3: Copying ini settings..."

    if [ -e ${NX_FILES}/bootloader/ini/00-android.ini ]; then
        while read line; do
            case ${line} in
                payload* ) ;;
                     id* ) ;;
                       * ) echo ${line} >> ${NX_FILES}/bootloader/ini/android.ini;;
            esac
        done < ${NX_FILES}/bootloader/ini/00-android.ini
    fi
}

uenvCopy() {
    printf "Step 2/3: Copying uenv settings..."

    if [ -e ${NX_SUBDIR}/uenv.txt ]; then
        while read line; do
            case ${line} in
                overlays* ) overlay_match ${line} ;;
                        * ) echo ${line} >> ${NX_FILES}/bootloader/ini/android.ini ;;
            esac
        done < ${NX_SUBDIR}/uenv.txt

        # check stored options and append new env vars to ini
        if [ ${EMMC} == 1 ]; then
            echo "emmc=1" >> ${NX_FILES}/bootloader/ini/android.ini
        fi
        if [ ${UART_PORT} != 0 ]; then
            echo "uart_port=${UART_PORT}" >> ${NX_FILES}/bootloader/ini/android.ini
        fi
    fi
}

cleanOld() {
    printf "Step 3/3: Removing old bootloader files..."

    rm -f ${NX_SUBDIR}/coreboot.rom
    rm -f ${NX_SUBDIR}/boot.scr
    rm -f ${NX_FILES}/00-android.ini
}

# ENTRY
iniCopy
uenvCopy
cleanOld
printf "Completed L4T-Loader migration!"
