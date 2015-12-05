From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v3] MAINTAINERS: add myself as Renesas Ethernet drivers reviewer
Date: Sat, 05 Dec 2015 04:50:48 +0300
Message-ID: <4240679.6nOnT2RPZY@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add myself as  a reviewer for the Renesas Ethernet drivers -- hopefully I
won't miss the buggy  patches anymore. :-)

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net.git' repo.

Changes in version 3:
- removed the status entry;

Changes in version 2:
- removed garbage from the changelog.

 MAINTAINERS |    7 +++++++
 1 file changed, 7 insertions(+)

Index: net/MAINTAINERS
===================================================================
--- net.orig/MAINTAINERS
+++ net/MAINTAINERS
@@ -8929,6 +8929,13 @@ F:	drivers/rpmsg/
 F:	Documentation/rpmsg.txt
 F:	include/linux/rpmsg.h
 
+RENESAS ETHERNET DRIVERS
+R:	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
+L:	netdev@vger.kernel.org
+L:	linux-sh@vger.kernel.org
+F:	drivers/net/ethernet/renesas/
+F:	include/linux/sh_eth.h
+
 RESET CONTROLLER FRAMEWORK
 M:	Philipp Zabel <p.zabel@pengutronix.de>
 S:	Maintained
