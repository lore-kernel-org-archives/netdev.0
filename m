From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] rtlwifi: Add firmware for rtl8192ee
Date: Tue, 28 Jan 2014 15:30:43 -0600
Message-ID: <1390944643-7388-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: dwmw2@infradead.org, ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:61111 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755737AbaA1VbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 16:31:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This firmware is for a driver for the Realtek RTL8192EE PCI WIFI device.
It came from a tarball from Realtek named
rtl_92ce_92se_92de_8723ae_88ee_8723be_92ee_linux_mac80211_0017.1224.2013.tar.gz
and is allowed to be distributed under the LICENCE.rtlwifi_firmware.txt license.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 WHENCE                  |   9 +++++++++
 rtlwifi/rtl8192eefw.bin | Bin 0 -> 32754 bytes
 2 files changed, 9 insertions(+)
 create mode 100644 rtlwifi/rtl8192eefw.bin

diff --git a/WHENCE b/WHENCE
index 0092f70..b2d6df9 100644
--- a/WHENCE
+++ b/WHENCE
@@ -1971,6 +1971,15 @@ Licence: Redistributable. See LICENCE.rtlwifi_firmware.txt for details.
 
 --------------------------------------------------------------------------
 
+Driver: rtl8192ee - Realtek 802.11n WLAN driver for RTL8192EE
+
+Info: Taken from Realtek version rtl_92ce_92se_92de_8723ae_88ee_8723be_92ee_linux_mac80211_0017.1224.2013
+File: rtlwifi/rtl8192eefw.bin
+
+Licence: Redistributable. See LICENCE.rtlwifi_firmware.txt for details.
+
+--------------------------------------------------------------------------
+
 Driver: r8169 - RealTek 8169/8168/8101 ethernet driver.
 
 File: rtl_nic/rtl8168d-1.fw
diff --git a/rtlwifi/rtl8192eefw.bin b/rtlwifi/rtl8192eefw.bin
new file mode 100644
index 0000000000000000000000000000000000000000..bede1ad79f9c5243484f31c790ef794d579c9b4b
GIT binary patch
literal 32754
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
QSXYengSk?jru9Sq59%k7NdN!<

literal 0
HcmV?d00001

-- 
1.8.4
