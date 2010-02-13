From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH] p54usb: Add usbid for Corega CG-WLUSB2GT.
Date: Sun, 14 Feb 2010 04:16:16 +0900
Message-ID: <4B76FA80.5070607@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, hirofumi@flycat.org
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linville@tuxdriver.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:43473 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753166Ab0BMTQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Feb 2010 14:16:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shimada Hirofumi <hirofumi@flycat.org>

p54usb: Add usbid for Corega CG-WLUSB2GT.

Signed-off-by: Shimada Hirofumi <hirofumi@flycat.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/net/wireless/p54/p54usb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
index 92af9b9..dcb484b 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -36,6 +36,7 @@ static struct usb_device_id p54u_table[] __devinitdata = {
 	/* Version 1 devices (pci chip + net2280) */
 	{USB_DEVICE(0x0506, 0x0a11)},	/* 3COM 3CRWE254G72 */
 	{USB_DEVICE(0x0707, 0xee06)},	/* SMC 2862W-G */
+	{USB_DEVICE(0x07aa, 0x001c)},	/* Corega CG-WLUSB2GT */
 	{USB_DEVICE(0x083a, 0x4501)},	/* Accton 802.11g WN4501 USB */
 	{USB_DEVICE(0x083a, 0x4502)},	/* Siemens Gigaset USB Adapter */
 	{USB_DEVICE(0x083a, 0x5501)},	/* Phillips CPWUA054 */
