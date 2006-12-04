From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/3] sky2: add PCI for 88ec033
Date: Mon, 4 Dec 2006 15:53:16 -0800
Message-ID: <20061204155316.102e6311@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:36488 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937153AbWLDXxx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 18:53:53 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add another new/missing pci id for 88ec033 chip.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c	2006-12-04 12:33:26.000000000 -0800
+++ sky2/drivers/net/sky2.c	2006-12-04 12:38:00.000000000 -0800
@@ -117,6 +117,7 @@
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4351) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4352) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4353) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4356) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4360) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4361) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4362) },

