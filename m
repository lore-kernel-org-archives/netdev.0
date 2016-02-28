From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v2 03/13] MAINTAINERS: update RDS entry
Date: Sat, 27 Feb 2016 18:19:40 -0800
Message-ID: <1456625990-4739-4-git-send-email-santosh.shilimkar@oracle.com>
References: <1456625990-4739-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42305 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992710AbcB1CUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 21:20:22 -0500
In-Reply-To: <1456625990-4739-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Chien Yen <chien.yen@oracle.com>
Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 MAINTAINERS | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 27393cf..08b084a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9067,10 +9067,14 @@ S:	Maintained
 F:	drivers/net/ethernet/rdc/r6040.c
 
 RDS - RELIABLE DATAGRAM SOCKETS
-M:	Chien Yen <chien.yen@oracle.com>
+M:	Santosh Shilimkar <santosh.shilimkar@oracle.com>
+L:	netdev@vger.kernel.org
+L:	linux-rdma@vger.kernel.org
 L:	rds-devel@oss.oracle.com (moderated for non-subscribers)
+W:	https://oss.oracle.com/projects/rds/
 S:	Supported
 F:	net/rds/
+F:	Documentation/networking/rds.txt
 
 READ-COPY UPDATE (RCU)
 M:	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
-- 
1.9.1
