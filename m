From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 4/4] netxen_nic: Bump up the version to 4.0.81
Date: Fri,  5 Apr 2013 08:36:43 -0400
Message-ID: <1365165403-18348-5-git-send-email-manish.chopra@qlogic.com>
References: <1365165403-18348-1-git-send-email-manish.chopra@qlogic.com>
Cc: netdev@vger.kernel.org, rajesh.borundia@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:45807 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1161628Ab3DEM76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Apr 2013 08:59:58 -0400
In-Reply-To: <1365165403-18348-1-git-send-email-manish.chopra@qlogic.com>
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
1.5.6
