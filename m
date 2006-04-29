From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [AX.25] Spelling fix
Date: Sat, 29 Apr 2006 15:24:27 +0100
Message-ID: <20060429142427.GA3684@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-hams-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:59333 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133567AbWD2Sqf (ORCPT
	<rfc822;netdev@vger.kernel.org> + 1 other);
	Sat, 29 Apr 2006 19:46:35 +0100
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

---
 net/ax25/ax25_route.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-net.git/net/ax25/ax25_route.c
===================================================================
--- linux-net.git.orig/net/ax25/ax25_route.c	2006-04-29 11:52:12.000000000 +0100
+++ linux-net.git/net/ax25/ax25_route.c	2006-04-29 15:23:13.000000000 +0100
@@ -360,7 +360,7 @@ struct file_operations ax25_route_fops =
 /*
  *	Find AX.25 route
  *
- *	Only routes with a refernce rout of zero can be destroyed.
+ *	Only routes with a reference count of zero can be destroyed.
  */
 static ax25_route *ax25_get_route(ax25_address *addr, struct net_device *dev)
 {
