From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 1/3] netxen: update module description
Date: Mon, 27 Dec 2010 00:43:41 -0800
Message-ID: <1293439423-25193-2-git-send-email-amit.salecha@qlogic.com>
References: <1293439423-25193-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:37501 "EHLO unm84.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752571Ab0L0IoG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Dec 2010 03:44:06 -0500
In-Reply-To: <1293439423-25193-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver supports only Intelligent Ethernet Adapters.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index ceeaac9..58a3643 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -38,7 +38,7 @@
 #include <linux/sysfs.h>
 #include <linux/aer.h>
 
-MODULE_DESCRIPTION("QLogic/NetXen (1/10) GbE Converged Ethernet Driver");
+MODULE_DESCRIPTION("QLogic/NetXen (1/10) GbE Intelligent Ethernet Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(NETXEN_NIC_LINUX_VERSIONID);
 MODULE_FIRMWARE(NX_UNIFIED_ROMIMAGE_NAME);
-- 
1.7.3.2

