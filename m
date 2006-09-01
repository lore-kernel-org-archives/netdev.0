From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sky2: more pci device id's
Date: Fri, 1 Sep 2006 14:52:04 -0700
Message-ID: <20060901145204.5f032935@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:4330 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751031AbWIAVwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 17:52:13 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some more Marvell device id's, these are from the latest SysKonnect
vendor driver version of sk98lin (8.36).

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |    3 +++
 1 file changed, 3 insertions(+)

--- sky2.orig/drivers/net/sky2.c	2006-09-01 14:49:49.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-09-01 14:49:56.000000000 -0700
@@ -106,6 +106,7 @@
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9000) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E00) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b00) },	/* DGE-560T */
+	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4001) }, 	/* DGE-550SX */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4340) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4341) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4342) },
@@ -117,6 +118,7 @@
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4350) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4351) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4352) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4353) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4360) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4361) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4362) },
@@ -126,6 +128,7 @@
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4366) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4367) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4368) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4369) },
 	{ 0 }
 };
 

-- 
VGER BF report: H 0.0313791
