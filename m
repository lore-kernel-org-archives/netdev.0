From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.12-rc5] tg3: add bcm5752 entry to pci.ids
Date: Fri, 27 May 2005 14:47:52 -0400
Message-ID: <20050527184750.GB11592@tuxdriver.com>
References: <04132005193844.8410@laptop> <04132005193844.8474@laptop> <20050421165956.55bdcb14.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	jgarzik@pobox.com, mchan@broadcom.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262519AbVE0Ssk@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050421165956.55bdcb14.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update pci.ids for BCM5752

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/pci/pci.ids |    1 +
 1 files changed, 1 insertion(+)

--- tg3-pci/drivers/pci/pci.ids.orig	2005-05-27 14:41:25.243607911 -0400
+++ tg3-pci/drivers/pci/pci.ids	2005-05-27 14:43:45.553326412 -0400
@@ -7173,6 +7173,7 @@
 	080f  Sentry5 DDR/SDR RAM Controller
 	0811  Sentry5 External Interface Core
 	0816  BCM3302 Sentry5 MIPS32 CPU
+	1600  NetXtreme BCM5752 Gigabit Ethernet PCI Express
 	1644  NetXtreme BCM5700 Gigabit Ethernet
 		1014 0277  Broadcom Vigil B5700 1000Base-T
 		1028 00d1  Broadcom BCM5700
-- 
John W. Linville
linville@tuxdriver.com
