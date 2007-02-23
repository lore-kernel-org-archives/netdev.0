From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/2] skge: comma consistency
Date: Fri, 23 Feb 2007 14:04:54 -0800
Message-ID: <20070223140454.63cd6a80@freekitty>
References: <20070223140300.1c93a375@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36517 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933231AbXBWWE6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Feb 2007 17:04:58 -0500
In-Reply-To: <20070223140300.1c93a375@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use comma's consistently.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 drivers/net/skge.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- sky2-dev.orig/drivers/net/skge.c	2007-02-23 13:53:25.000000000 -0800
+++ sky2-dev/drivers/net/skge.c	2007-02-23 13:53:41.000000000 -0800
@@ -77,13 +77,13 @@
 	{ PCI_DEVICE(PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3C940B) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_GE) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_YU) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, PCI_DEVICE_ID_DLINK_DGE510T), },
+	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, PCI_DEVICE_ID_DLINK_DGE510T) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b01) },	/* DGE-530T */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4320) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x5005) }, /* Belkin */
 	{ PCI_DEVICE(PCI_VENDOR_ID_CNET, PCI_DEVICE_ID_CNET_GIGACARD) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_LINKSYS, PCI_DEVICE_ID_LINKSYS_EG1064) },
-	{ PCI_VENDOR_ID_LINKSYS, 0x1032, PCI_ANY_ID, 0x0015, },
+	{ PCI_VENDOR_ID_LINKSYS, 0x1032, PCI_ANY_ID, 0x0015 },
 	{ 0 }
 };
 MODULE_DEVICE_TABLE(pci, skge_id_table);
