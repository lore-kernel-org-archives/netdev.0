From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 12/12] netxen: update version to 4.0.41
Date: Sun, 26 Jul 2009 23:07:47 -0700
Message-ID: <1248674867-18821-13-git-send-email-dhananjay@netxen.com>
References: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:33582 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751471AbZG0GHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2009 02:07:49 -0400
In-Reply-To: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 9527f31..d4ac151 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -57,8 +57,8 @@
 
 #define _NETXEN_NIC_LINUX_MAJOR 4
 #define _NETXEN_NIC_LINUX_MINOR 0
-#define _NETXEN_NIC_LINUX_SUBVERSION 30
-#define NETXEN_NIC_LINUX_VERSIONID  "4.0.30"
+#define _NETXEN_NIC_LINUX_SUBVERSION 41
+#define NETXEN_NIC_LINUX_VERSIONID  "4.0.41"
 
 #define NETXEN_VERSION_CODE(a, b, c)	(((a) << 24) + ((b) << 16) + (c))
 #define _major(v)	(((v) >> 24) & 0xff)
-- 
1.6.0.2

