From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 5/5] netxen_nic: Update version to 4.0.81
Date: Thu, 30 May 2013 15:51:38 -0400
Message-ID: <1369943498-1732-6-git-send-email-manish.chopra@qlogic.com>
References: <1369943498-1732-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <rajesh.borundia@qlogic.com>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0187.outbound.messaging.microsoft.com ([213.199.154.187]:19562
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757616Ab3E3URD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 16:17:03 -0400
In-Reply-To: <1369943498-1732-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
index e5ab1ec..3fe09ab 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
@@ -53,8 +53,8 @@
 
 #define _NETXEN_NIC_LINUX_MAJOR 4
 #define _NETXEN_NIC_LINUX_MINOR 0
-#define _NETXEN_NIC_LINUX_SUBVERSION 80
-#define NETXEN_NIC_LINUX_VERSIONID  "4.0.80"
+#define _NETXEN_NIC_LINUX_SUBVERSION 81
+#define NETXEN_NIC_LINUX_VERSIONID  "4.0.81"
 
 #define NETXEN_VERSION_CODE(a, b, c)	(((a) << 24) + ((b) << 16) + (c))
 #define _major(v)	(((v) >> 24) & 0xff)
-- 
1.7.1
