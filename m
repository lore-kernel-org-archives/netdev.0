From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 1/7] netxen; update version to 4.0.56
Date: Thu, 15 Oct 2009 23:09:07 -0700
Message-ID: <1255673353-31797-2-git-send-email-dhananjay@netxen.com>
References: <1255673353-31797-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:45927 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753689AbZJPGJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2009 02:09:50 -0400
In-Reply-To: <1255673353-31797-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 1bdb8f4..3d990e5 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -53,8 +53,8 @@
 
 #define _NETXEN_NIC_LINUX_MAJOR 4
 #define _NETXEN_NIC_LINUX_MINOR 0
-#define _NETXEN_NIC_LINUX_SUBVERSION 50
-#define NETXEN_NIC_LINUX_VERSIONID  "4.0.50"
+#define _NETXEN_NIC_LINUX_SUBVERSION 56
+#define NETXEN_NIC_LINUX_VERSIONID  "4.0.56"
 
 #define NETXEN_VERSION_CODE(a, b, c)	(((a) << 24) + ((b) << 16) + (c))
 #define _major(v)	(((v) >> 24) & 0xff)
-- 
1.6.0.2

