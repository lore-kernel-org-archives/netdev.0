From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 13/13] netxen: raise version to 4.0.23
Date: Mon, 12 Jan 2009 11:23:11 -0800
Message-ID: <1231788191-23794-14-git-send-email-dhananjay@netxen.com>
References: <1231788191-23794-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:56015 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756344AbZALTex (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2009 14:34:53 -0500
In-Reply-To: <1231788191-23794-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 1fb60a5..e21792f 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -41,8 +41,8 @@
 
 #define _NETXEN_NIC_LINUX_MAJOR 4
 #define _NETXEN_NIC_LINUX_MINOR 0
-#define _NETXEN_NIC_LINUX_SUBVERSION 11
-#define NETXEN_NIC_LINUX_VERSIONID  "4.0.11"
+#define _NETXEN_NIC_LINUX_SUBVERSION 23
+#define NETXEN_NIC_LINUX_VERSIONID  "4.0.23"
 
 #define NETXEN_VERSION_CODE(a, b, c)	(((a) << 16) + ((b) << 8) + (c))
 
-- 
1.6.0.2

