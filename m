From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH 03/13] MAINTAINERS: update RDS entry
Date: Fri, 26 Feb 2016 21:43:48 -0800
Message-ID: <1456551838-9080-4-git-send-email-santosh.shilimkar@oracle.com>
References: <1456551838-9080-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456551838-9080-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Acked-by: Chien Yen <chien.yen@oracle.com>
Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 MAINTAINERS | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 355e1c8..9d79bea 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9081,10 +9081,14 @@ S:	Maintained
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
