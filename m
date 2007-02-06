From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 6/7] sky2: add new chip ids
Date: Tue, 06 Feb 2007 10:45:44 -0800
Message-ID: <20070206184855.342726000@linux-foundation.org>
References: <20070206184538.675048000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:45772 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965223AbXBFS40 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 13:56:26 -0500
Content-Disposition: inline; filename=sky2-chip-ids
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

More new chip id's from vendor driver version 10.0.4.3

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    4 ++++
 1 file changed, 4 insertions(+)

--- sky2-dev.orig/drivers/net/sky2.c	2007-02-06 10:44:26.000000000 -0800
+++ sky2-dev/drivers/net/sky2.c	2007-02-06 10:44:29.000000000 -0800
@@ -105,6 +105,7 @@
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b00) },	/* DGE-560T */
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4001) }, 	/* DGE-550SX */
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4B02) },	/* DGE-560SX */
+	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4B03) },	/* DGE-550T */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4340) }, /* 88E8021 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4341) }, /* 88E8022 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4342) }, /* 88E8061 */
@@ -126,6 +127,9 @@
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4366) }, /* 88EC036 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4367) }, /* 88EC032 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4368) }, /* 88EC034 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4369) }, /* 88EC042 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436A) }, /* 88E8058 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436B) }, /* 88E8071 */
 	{ 0 }
 };
 

--
Stephen Hemminger <shemminger@linux-foundation.org>

