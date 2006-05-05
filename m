From: Stefano Brivio <stefano.brivio@polimi.it>
Subject: [PATCH 3/3] bcm43xx-d80211: add PCI ID for bcm4319
Date: Fri, 5 May 2006 21:59:34 +0200
Message-ID: <20060505215934.718bf36b@localhost>
References: <20060505215542.25d310dd@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.polimi.it ([131.175.12.3]:3558 "EHLO polimi.it")
	by vger.kernel.org with ESMTP id S1751735AbWEEUAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 16:00:37 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060505215542.25d310dd@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add PCI ID for bcm4319.

Signed-off-by: Stefano Brivio <stefano.brivio@polimi.it>

Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-05-05 00:50:00.370034536 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-05-05 02:56:42.216378232 +0200
@@ -132,6 +132,8 @@ MODULE_PARM_DESC(fwpostfix, "Postfix for
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
