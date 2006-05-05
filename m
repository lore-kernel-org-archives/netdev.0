From: Stefano Brivio <stefano.brivio@polimi.it>
Subject: [PATCH 0/2] bcm43xx: fix whitespace
Date: Fri, 5 May 2006 02:58:29 +0200
Message-ID: <20060505025829.5d4b072f@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.polimi.it ([131.175.12.3]:10190 "EHLO polimi.it")
	by vger.kernel.org with ESMTP id S1751513AbWEEBDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 May 2006 21:03:22 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This applies to 2.6.17-rc3.

--

Fix whitespace.

Signed-off-by: Stefano Brivio <stefano.brivio@polimi.it>

Index: linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-05-05 00:50:00.370034536 +0200
+++ linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-05-05 02:43:44.981535888 +0200
@@ -128,13 +128,13 @@ MODULE_PARM_DESC(fwpostfix, "Postfix for
 	static struct pci_device_id bcm43xx_pci_tbl[] = {
 	/* Broadcom 4303 802.11b */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4301, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-		/* Broadcom 4307 802.11b */
+	/* Broadcom 4307 802.11b */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4307, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-		/* Broadcom 4318 802.11b/g */
+	/* Broadcom 4318 802.11b/g */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4318, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4306 802.11b/g */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4320, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-		/* Broadcom 4306 802.11a */
+	/* Broadcom 4306 802.11a */
 //	{ PCI_VENDOR_ID_BROADCOM, 0x4321, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4309 802.11a/b/g */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4324, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },


--
Ciao
Stefano
