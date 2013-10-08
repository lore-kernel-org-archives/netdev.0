From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] rtlwifi: Add new firmware files for rtl8188eu
Date: Tue, 08 Oct 2013 18:28:25 -0500
Message-ID: <52549519.1010207@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org
To: dwmw2@infradead.org, Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f176.google.com ([209.85.161.176]:65218 "EHLO
	mail-gg0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755341Ab3JHXeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 19:34:12 -0400
Received: by mail-gg0-f176.google.com with SMTP id s2so6274ggf.35
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 16:34:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vendor driver RTL8188EUS_linux_v4.1.4_6773.20130222 contains
firmware in the form of data statements. This info has been extracted
into a binary file.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
  WHENCE                  |   9 +++++++++
  rtlwifi/rtl8188eufw.bin | Bin 0 -> 13904 bytes
  2 files changed, 9 insertions(+)
  create mode 100644 rtlwifi/rtl8188eufw.bin

diff --git a/WHENCE b/WHENCE
index 27865b6..ee963a0 100644
--- a/WHENCE
+++ b/WHENCE
@@ -1893,6 +1893,15 @@ Licence: Redistributable. See 
LICENCE.rtlwifi_firmware.txt for details.
   --------------------------------------------------------------------------
  +Driver: rtl8188eu - Realtek 802.11n WLAN driver for RTL8188EU
+
+Info: Taken from Realtek version RTL8188EUS_linux_v4.1.4_6773.20130222
+File: rtlwifi/rtl8188eufw.bin
+
+Licence: Redistributable. See LICENCE.rtlwifi_firmware.txt for details.
+
+--------------------------------------------------------------------------
+
  Driver: r8169 - RealTek 8169/8168/8101 ethernet driver.
   File: rtl_nic/rtl8168d-1.fw
diff --git a/rtlwifi/rtl8188eufw.bin b/rtlwifi/rtl8188eufw.bin
new file mode 100644
index 
0000000000000000000000000000000000000000..4ae7e1c5deb7846e59c461546a49679504ffed28
GIT binary patch
literal 13904
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
OE+=Occa@IUp8UUyqelq<

literal 0
HcmV?d00001

-- 
1.8.1.4
