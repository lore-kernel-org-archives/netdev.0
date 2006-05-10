From: Stefano Brivio <stefano.brivio@polimi.it>
Subject: [PATCH 2/2] bcm43xx-d80211: add PCI ID for bcm4319. (#2)
Date: Thu, 11 May 2006 01:11:16 +0200
Message-ID: <20060511011116.5167fc2d@localhost>
References: <20060510221056.350408000@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.polimi.it ([131.175.12.3]:13496 "EHLO polimi.it")
	by vger.kernel.org with ESMTP id S965073AbWEJXLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 19:11:40 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060510221056.350408000@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add PCI ID for bcm4319.

Signed-off-by: Stefano Brivio <stefano.brivio@polimi.it>
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -128,6 +128,8 @@ static struct pci_device_id bcm43xx_pci_
 	{ PCI_VENDOR_ID_BROADCOM, 0x4307, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4318 802.11b/g */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4318, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	/* Broadcom 4319 802.11b/g */
+	{ PCI_VENDOR_ID_BROADCOM, 0x4319, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4306 802.11b/g */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4320, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4306 802.11a */


--
Ciao
Stefano
