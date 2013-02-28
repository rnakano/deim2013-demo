#!/bin/bash
tshark -i en0 -I -R "(wlan.fcs_good == 1) && (wlan.fc.type_subtype == 0x04) && (wlan.da == ff:ff:ff:ff:ff:ff)" -t ad -I -l -T fields -e frame.time -e wlan.fc.type_subtype -e wlan.sa -e radiotap.dbm_antsignal -e radiotap.dbm_antnoise -e wlan.seq -e wlan_mgt.ssid
