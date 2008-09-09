From: Chris Snook <csnook@redhat.com>
Subject: [PATCH 1/4] atlx: add atl2 pci id
Date: Tue, 9 Sep 2008 02:15:56 -0400
Message-ID: <20080909061556.GA18425@file.rdu.redhat.com>
References: <20080909061247.GA17834@file.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, jcliburn@gmail.com
To: jeff@garzik.org, netdev@vger.kernel.org,
	atl2-test@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44893 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752005AbYIIGQr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 02:16:47 -0400
Content-Disposition: inline
In-Reply-To: <20080909061247.GA17834@file.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Snook <csnook@redhat.com>

Add the pci id for the Atheros L2 NIC.

Signed-off-by: Chris Snook <csnook@redhat.com>

diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 6595382..6864ef7 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2179,6 +2179,7 @@
 
 #define PCI_VENDOR_ID_ATTANSIC		0x1969
 #define PCI_DEVICE_ID_ATTANSIC_L1	0x1048
+#define PCI_DEVICE_ID_ATTANSIC_L2	0x2048
 
 #define PCI_VENDOR_ID_JMICRON		0x197B
 #define PCI_DEVICE_ID_JMICRON_JMB360	0x2360
