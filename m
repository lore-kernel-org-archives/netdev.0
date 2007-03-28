From: Chris Snook <csnook@redhat.com>
Subject: [PATCH] add Attansic L2 PCI ID
Date: Wed, 28 Mar 2007 19:47:38 -0400
Message-ID: <20070328234738.GA8042@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiong.huang@atheros.com, jacliburn@bellsouth.net,
	netdev@vger.kernel.org, csnook@redhat.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42824 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934046AbXC1Xrr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 19:47:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Snook <csnook@redhat.com>

Add PCI ID for the Attansic L2 100 Mb ethernet adapter.

Signed-off-by: Chris Snook <csnook@redhat.com>

--- linux-2.6.21-rc5.orig/include/linux/pci_ids.h	2007-03-27 23:26:50.000000000 -0400
+++ linux-2.6.21-rc5/include/linux/pci_ids.h	2007-03-28 15:11:03.000000000 -0400
@@ -2090,6 +2090,7 @@
 
 #define PCI_VENDOR_ID_ATTANSIC		0x1969
 #define PCI_DEVICE_ID_ATTANSIC_L1	0x1048
+#define PCI_DEVICE_ID_ATTANSIC_L2	0x2048
 
 #define PCI_VENDOR_ID_JMICRON		0x197B
 #define PCI_DEVICE_ID_JMICRON_JMB360	0x2360
