From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 8/8] netxen: update version to 4.0.73
Date: Wed, 24 Mar 2010 06:29:23 -0700
Message-ID: <1269437363-2606-9-git-send-email-amit.salecha@qlogic.com>
References: <1269437363-2606-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:16456 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756259Ab0CXN30 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Mar 2010 09:29:26 -0400
In-Reply-To: <1269437363-2606-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 33ae5e1..174ac8e 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -53,8 +53,8 @@
 
 #define _NETXEN_NIC_LINUX_MAJOR 4
 #define _NETXEN_NIC_LINUX_MINOR 0
-#define _NETXEN_NIC_LINUX_SUBVERSION 72
-#define NETXEN_NIC_LINUX_VERSIONID  "4.0.72"
+#define _NETXEN_NIC_LINUX_SUBVERSION 73
+#define NETXEN_NIC_LINUX_VERSIONID  "4.0.73"
 
 #define NETXEN_VERSION_CODE(a, b, c)	(((a) << 24) + ((b) << 16) + (c))
 #define _major(v)	(((v) >> 24) & 0xff)
-- 
1.6.0.2

