From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 6/6] netxen: update version to 4.0.50
Date: Sat,  5 Sep 2009 20:43:12 -0700
Message-ID: <1252208592-2240-7-git-send-email-dhananjay@netxen.com>
References: <1252208592-2240-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:25072 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1754045AbZIFDnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Sep 2009 23:43:13 -0400
In-Reply-To: <1252208592-2240-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index df03ea4..2a52479 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -58,8 +58,8 @@
 
 #define _NETXEN_NIC_LINUX_MAJOR 4
 #define _NETXEN_NIC_LINUX_MINOR 0
-#define _NETXEN_NIC_LINUX_SUBVERSION 41
-#define NETXEN_NIC_LINUX_VERSIONID  "4.0.41"
+#define _NETXEN_NIC_LINUX_SUBVERSION 50
+#define NETXEN_NIC_LINUX_VERSIONID  "4.0.50"
 
 #define NETXEN_VERSION_CODE(a, b, c)	(((a) << 24) + ((b) << 16) + (c))
 #define _major(v)	(((v) >> 24) & 0xff)
-- 
1.6.0.2

