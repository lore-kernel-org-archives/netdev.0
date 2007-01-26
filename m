From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [USBNET] PEGASUS: Fix typo in Corega products.
Date: Fri, 26 Jan 2007 22:59:01 +0900 (JST)
Message-ID: <20070126.225901.112152229.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:47059 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965672AbXAZN5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 08:57:47 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

s/FEter/FEther/.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/usb/net/pegasus.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/usb/net/pegasus.h b/drivers/usb/net/pegasus.h
index 98f6898..c746782 100644
--- a/drivers/usb/net/pegasus.h
+++ b/drivers/usb/net/pegasus.h
@@ -214,9 +214,9 @@ PEGASUS_DEV( "Billionton USBEL-100", VENDOR_BILLIONTON, 0x0988,
 		DEFAULT_GPIO_RESET )
 PEGASUS_DEV( "Billionton USBE-100", VENDOR_BILLIONTON, 0x8511,
 		DEFAULT_GPIO_RESET | PEGASUS_II )
-PEGASUS_DEV( "Corega FEter USB-TX", VENDOR_COREGA, 0x0004,
+PEGASUS_DEV( "Corega FEther USB-TX", VENDOR_COREGA, 0x0004,
 		DEFAULT_GPIO_RESET )
-PEGASUS_DEV( "Corega FEter USB-TXS", VENDOR_COREGA, 0x000d,
+PEGASUS_DEV( "Corega FEther USB-TXS", VENDOR_COREGA, 0x000d,
 		DEFAULT_GPIO_RESET | PEGASUS_II )
 PEGASUS_DEV( "D-Link DSB-650TX", VENDOR_DLINK, 0x4001,
 		DEFAULT_GPIO_RESET )
-- 
1.4.4.1.g562ce

