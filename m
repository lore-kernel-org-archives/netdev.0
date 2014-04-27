From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] rtlwifi: rtl8723be: Add firmware
Date: Sun, 27 Apr 2014 15:28:24 -0500
Message-ID: <1398630504-11649-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: dwmw2@infradead.org, ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:59306 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbaD0U2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2014 16:28:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit provides firmware for the RTL8723CE, which is in kernel 3.15.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 WHENCE                  |   9 +++++++++
 rtlwifi/rtl8723befw.bin | Bin 0 -> 30996 bytes
 2 files changed, 9 insertions(+)
 create mode 100644 rtlwifi/rtl8723befw.bin

diff --git a/WHENCE b/WHENCE
index ca0f30b..27dca96 100644
--- a/WHENCE
+++ b/WHENCE
@@ -1937,6 +1937,15 @@ Licence: Redistributable. See LICENCE.rtlwifi_firmware.txt for details.
 
 --------------------------------------------------------------------------
 
+Driver: rtl8723be - Realtek 802.11n WLAN driver for RTL8723BE
+
+Info: Taken from driver sent to me from Realtek
+File: rtlwifi/rtl8723befw.bin
+
+Licence: Redistributable. See LICENCE.rtlwifi_firmware.txt for details.
+
+--------------------------------------------------------------------------
+
 Driver: r8723au - Realtek 802.11n WLAN driver for RTL8723AU
 
 Info: Taken from Realtek driver rtl8723A_WiFi_linux_v4.1.3_6044.20121224
diff --git a/rtlwifi/rtl8723befw.bin b/rtlwifi/rtl8723befw.bin
new file mode 100644
index 0000000000000000000000000000000000000000..466bab28656f3d41ebb019b7dc248cfb1438df97
GIT binary patch
literal 30996
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

literal 0
HcmV?d00001

-- 
1.8.4.5
