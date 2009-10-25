From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 6/6] netxen: update version to 4.0.65
Date: Sat, 24 Oct 2009 19:04:03 -0700
Message-ID: <1256436243-5736-7-git-send-email-dhananjay@netxen.com>
References: <1256436243-5736-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:1508 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752457AbZJYCEA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Oct 2009 22:04:00 -0400
In-Reply-To: <1256436243-5736-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 5982dac..645450d 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -53,8 +53,8 @@
 
 #define _NETXEN_NIC_LINUX_MAJOR 4
 #define _NETXEN_NIC_LINUX_MINOR 0
-#define _NETXEN_NIC_LINUX_SUBVERSION 62
-#define NETXEN_NIC_LINUX_VERSIONID  "4.0.62"
+#define _NETXEN_NIC_LINUX_SUBVERSION 65
+#define NETXEN_NIC_LINUX_VERSIONID  "4.0.65"
 
 #define NETXEN_VERSION_CODE(a, b, c)	(((a) << 24) + ((b) << 16) + (c))
 #define _major(v)	(((v) >> 24) & 0xff)
-- 
1.6.0.2

