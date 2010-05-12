From: SECO <secowu@gmail.com>
Subject: comapt-wireless-2010-05-11,b43 can not be work.
Date: Wed, 12 May 2010 21:46:16 +0800
Message-ID: <AANLkTik17Y9sl8P57PqRXRpJrSxvhK7W7I-n1izGMu5D@mail.gmail.com>
Reply-To: seco.wu@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: majordomo@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:52562 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113Ab0ELNqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 09:46:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Sir,

           UBUNTU 10.04 desktop
           uname -a
Linux ubuntu 2.6.32-22-generic #33-Ubuntu SMP Wed Apr 28 13:27:30 UTC
2010 i686 GNU/Linux

           What's the matter with it? TKS

seco@ubuntu:~/desktop/compat-wireless-2010-05-11$ sudo dmesg | grep b43
[    1.097857] b43-pci-bridge 0000:30:00.0: PCI INT A -> GSI 18
(level, low) -> IRQ 18
[    1.097867] b43-pci-bridge 0000:30:00.0: setting latency timer to 64
[   22.341327] b43: disagrees about version of symbol
ieee80211_get_response_rate
[   22.341334] b43: Unknown symbol ieee80211_get_response_rate
[   22.342308] b43: disagrees about version of symbol ieee80211_free_hw
[   22.342311] b43: Unknown symbol ieee80211_free_hw
[   22.342577] b43: disagrees about version of symbol ieee80211_alloc_hw
[   22.342579] b43: Unknown symbol ieee80211_alloc_hw
[   22.342756] b43: disagrees about version of symbol ieee80211_register_hw
[   22.342758] b43: Unknown symbol ieee80211_register_hw
[   22.343024] b43: disagrees about version of symbol
__ieee80211_get_radio_led_name
[   22.343026] b43: Unknown symbol __ieee80211_get_radio_led_name
[   22.343128] b43: disagrees about version of symbol
ieee80211_generic_frame_duration
[   22.343131] b43: Unknown symbol ieee80211_generic_frame_duration
[   22.343232] b43: disagrees about version of symbol ieee80211_wake_queue
[   22.343235] b43: Unknown symbol ieee80211_wake_queue
[   22.343337] b43: disagrees about version of symbol ieee80211_get_tkip_key
[   22.343339] b43: Unknown symbol ieee80211_get_tkip_key
[   22.343644] b43: disagrees about version of symbol
__ieee80211_get_tx_led_name
[   22.343647] b43: Unknown symbol __ieee80211_get_tx_led_name
[   22.343757] b43: disagrees about version of symbol wiphy_rfkill_set_hw_state
[   22.343760] b43: Unknown symbol wiphy_rfkill_set_hw_state
[   22.344212] b43: disagrees about version of symbol
__ieee80211_get_rx_led_name
[   22.344215] b43: Unknown symbol __ieee80211_get_rx_led_name
[   22.344779] b43: disagrees about version of symbol
ieee80211_queue_delayed_work
[   22.344782] b43: Unknown symbol ieee80211_queue_delayed_work
[   22.344958] b43: disagrees about version of symbol ieee80211_ctstoself_get
[   22.344961] b43: Unknown symbol ieee80211_ctstoself_get
[   22.345130] b43: disagrees about version of symbol ieee80211_rx
[   22.345133] b43: Unknown symbol ieee80211_rx
[   22.345394] b43: disagrees about version of symbol ieee80211_wake_queues
[   22.345397] b43: Unknown symbol ieee80211_wake_queues
[   22.345635] b43: disagrees about version of symbol ieee80211_tx_status
[   22.345637] b43: Unknown symbol ieee80211_tx_status
[   22.345738] b43: disagrees about version of symbol ieee80211_stop_queue
[   22.345740] b43: Unknown symbol ieee80211_stop_queue
[   22.345992] b43: disagrees about version of symbol
__ieee80211_get_assoc_led_name
[   22.345995] b43: Unknown symbol __ieee80211_get_assoc_led_name
[   22.346100] b43: disagrees about version of symbol wiphy_rfkill_start_polling
[   22.346103] b43: Unknown symbol wiphy_rfkill_start_polling
[   22.346376] b43: disagrees about version of symbol ieee80211_unregister_hw
[   22.346378] b43: Unknown symbol ieee80211_unregister_hw
[   22.346985] b43: disagrees about version of symbol ieee80211_rts_get
[   22.346988] b43: Unknown symbol ieee80211_rts_get
[   22.347110] b43: Unknown symbol ieee80211_beacon_get
[   22.347318] b43: disagrees about version of symbol ieee80211_queue_work
[   22.347320] b43: Unknown symbol ieee80211_queue_work
[  182.979820] b43: disagrees about version of symbol
ieee80211_get_response_rate
[  182.979827] b43: Unknown symbol ieee80211_get_response_rate
[  182.980856] b43: disagrees about version of symbol ieee80211_free_hw
[  182.980859] b43: Unknown symbol ieee80211_free_hw
[  182.981180] b43: disagrees about version of symbol ieee80211_alloc_hw
[  182.981183] b43: Unknown symbol ieee80211_alloc_hw
[  182.981369] b43: disagrees about version of symbol ieee80211_register_hw
[  182.981372] b43: Unknown symbol ieee80211_register_hw
[  182.982228] b43: disagrees about version of symbol
__ieee80211_get_radio_led_name
[  182.982232] b43: Unknown symbol __ieee80211_get_radio_led_name
[  182.982345] b43: disagrees about version of symbol
ieee80211_generic_frame_duration
[  182.982348] b43: Unknown symbol ieee80211_generic_frame_duration
[  182.982460] b43: disagrees about version of symbol ieee80211_wake_queue
[  182.982463] b43: Unknown symbol ieee80211_wake_queue
[  182.982573] b43: disagrees about version of symbol ieee80211_get_tkip_key
[  182.982576] b43: Unknown symbol ieee80211_get_tkip_key
[  182.982903] b43: disagrees about version of symbol
__ieee80211_get_tx_led_name
[  182.982907] b43: Unknown symbol __ieee80211_get_tx_led_name
[  182.983027] b43: disagrees about version of symbol wiphy_rfkill_set_hw_state
[  182.983030] b43: Unknown symbol wiphy_rfkill_set_hw_state
[  182.983457] b43: disagrees about version of symbol
__ieee80211_get_rx_led_name
[  182.983460] b43: Unknown symbol __ieee80211_get_rx_led_name
[  182.984058] b43: disagrees about version of symbol
ieee80211_queue_delayed_work
[  182.984061] b43: Unknown symbol ieee80211_queue_delayed_work
[  182.984247] b43: disagrees about version of symbol ieee80211_ctstoself_get
[  182.984251] b43: Unknown symbol ieee80211_ctstoself_get
[  182.984430] b43: disagrees about version of symbol ieee80211_rx
[  182.984433] b43: Unknown symbol ieee80211_rx
[  182.984714] b43: disagrees about version of symbol ieee80211_wake_queues
[  182.984717] b43: Unknown symbol ieee80211_wake_queues
[  182.984976] b43: disagrees about version of symbol ieee80211_tx_status
[  182.984979] b43: Unknown symbol ieee80211_tx_status
[  182.985111] b43: disagrees about version of symbol ieee80211_stop_queue
[  182.985114] b43: Unknown symbol ieee80211_stop_queue
[  182.985385] b43: disagrees about version of symbol
__ieee80211_get_assoc_led_name
[  182.985389] b43: Unknown symbol __ieee80211_get_assoc_led_name
[  182.985505] b43: disagrees about version of symbol wiphy_rfkill_start_polling
[  182.985508] b43: Unknown symbol wiphy_rfkill_start_polling
[  182.985800] b43: disagrees about version of symbol ieee80211_unregister_hw
[  182.985803] b43: Unknown symbol ieee80211_unregister_hw
[  182.987802] b43: disagrees about version of symbol ieee80211_rts_get
[  182.987805] b43: Unknown symbol ieee80211_rts_get
[  182.987936] b43: Unknown symbol ieee80211_beacon_get
[  182.988166] b43: disagrees about version of symbol ieee80211_queue_work
[  182.988170] b43: Unknown symbol ieee80211_queue_work
[  715.137153] b43: disagrees about version of symbol
ieee80211_get_response_rate
[  715.137175] b43: Unknown symbol ieee80211_get_response_rate
[  715.139585] b43: disagrees about version of symbol ieee80211_free_hw
[  715.139591] b43: Unknown symbol ieee80211_free_hw
[  715.140289] b43: disagrees about version of symbol ieee80211_alloc_hw
[  715.140295] b43: Unknown symbol ieee80211_alloc_hw
[  715.140719] b43: disagrees about version of symbol ieee80211_register_hw
[  715.140725] b43: Unknown symbol ieee80211_register_hw
[  715.143098] b43: disagrees about version of symbol
__ieee80211_get_radio_led_name
[  715.143107] b43: Unknown symbol __ieee80211_get_radio_led_name
[  715.143362] b43: disagrees about version of symbol
ieee80211_generic_frame_duration
[  715.143368] b43: Unknown symbol ieee80211_generic_frame_duration
[  715.143623] b43: disagrees about version of symbol ieee80211_wake_queue
[  715.143628] b43: Unknown symbol ieee80211_wake_queue
[  715.143879] b43: disagrees about version of symbol ieee80211_get_tkip_key
[  715.143884] b43: Unknown symbol ieee80211_get_tkip_key
[  715.144734] b43: disagrees about version of symbol
__ieee80211_get_tx_led_name
[  715.144740] b43: Unknown symbol __ieee80211_get_tx_led_name
[  715.145026] b43: disagrees about version of symbol wiphy_rfkill_set_hw_state
[  715.145032] b43: Unknown symbol wiphy_rfkill_set_hw_state
[  715.146009] b43: disagrees about version of symbol
__ieee80211_get_rx_led_name
[  715.146015] b43: Unknown symbol __ieee80211_get_rx_led_name
[  715.147362] b43: disagrees about version of symbol
ieee80211_queue_delayed_work
[  715.147368] b43: Unknown symbol ieee80211_queue_delayed_work
[  715.147792] b43: disagrees about version of symbol ieee80211_ctstoself_get
[  715.147798] b43: Unknown symbol ieee80211_ctstoself_get
[  715.148231] b43: disagrees about version of symbol ieee80211_rx
[  715.148237] b43: Unknown symbol ieee80211_rx
[  715.148898] b43: disagrees about version of symbol ieee80211_wake_queues
[  715.148910] b43: Unknown symbol ieee80211_wake_queues
[  715.149522] b43: disagrees about version of symbol ieee80211_tx_status
[  715.149529] b43: Unknown symbol ieee80211_tx_status
[  715.149786] b43: disagrees about version of symbol ieee80211_stop_queue
[  715.149792] b43: Unknown symbol ieee80211_stop_queue
[  715.150435] b43: disagrees about version of symbol
__ieee80211_get_assoc_led_name
[  715.150442] b43: Unknown symbol __ieee80211_get_assoc_led_name
[  715.150716] b43: disagrees about version of symbol wiphy_rfkill_start_polling
[  715.150722] b43: Unknown symbol wiphy_rfkill_start_polling
[  715.151411] b43: disagrees about version of symbol ieee80211_unregister_hw
[  715.151417] b43: Unknown symbol ieee80211_unregister_hw
[  715.155035] b43: disagrees about version of symbol ieee80211_rts_get
[  715.155043] b43: Unknown symbol ieee80211_rts_get
[  715.155344] b43: Unknown symbol ieee80211_beacon_get
[  715.155865] b43: disagrees about version of symbol ieee80211_queue_work
[  715.155872] b43: Unknown symbol ieee80211_queue_work
seco@ubuntu:~/desktop/compat-wireless-2010-05-11$
-- 
Best Regards
--------------------
SECO

--------------------------------------------------------------------------------
This information in this e-mail is confidential and may well also be
legally privileged. It is intended solely for the addressee. If you
have received it in error, you are on notice of its status. Please
notify us immediately and then destroy this message. Please do not
copy it or use it for any purposes, or disclose its contents to any
other person: to do so could be a breach of confidence. Thank you for
your co-operation.
--------------------------------------------------------------------------------
