From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 12/24] RT2x00: Add new rt73usb devices
Date: Wed, 26 Jul 2006 19:05:15 +0200
Message-ID: <200607261905.16035.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:46239 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1030308AbWGZRHg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 13:07:36 -0400
Received: by nf-out-0910.google.com with SMTP id o25so812592nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 10:07:35 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

Add new rt73usb devices.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-scan/drivers/net/wireless/d80211/rt2x00/rt73usb.c 
wireless-dev-newdev/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-scan/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-23 
22:35:17.000000000 +0200
+++ wireless-dev-newdev/drivers/net/wireless/d80211/rt2x00/rt73usb.c	
2006-07-23 22:47:41.000000000 +0200
@@ -3119,6 +3119,8 @@
 	{ USB_DEVICE(0x07d1, 0x3c04) },
 	/* Gigabyte */
 	{ USB_DEVICE(0x1044, 0x8008) },
+	/* Linksys */
+	{ USB_DEVICE(0x13b1, 0x0020) },
 	/* MSI */
 	{ USB_DEVICE(0x0db0, 0x6877) },
 	{ USB_DEVICE(0x0db0, 0xa874) },
@@ -3127,6 +3129,8 @@
 	{ USB_DEVICE(0x148f, 0x2671) },
 	/* Qcom */
 	{ USB_DEVICE(0x18e8, 0x6196) },
+	/* Sitecom */
+	{ USB_DEVICE(0x0df6, 0x9712) },
 	{ 0, }
 };
 
