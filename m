From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2.4] U32: Remove unused hgenerator field in tc_u_hnode
Date: Sat, 23 Oct 2004 00:11:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022221125.GH21977@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.4.28-pre4-bk6.orig/net/sched/cls_u32.c	2004-10-22 10:58:23.000000000 +0200
+++ linux-2.4.28-pre4-bk6/net/sched/cls_u32.c	2004-10-23 00:03:47.000000000 +0200
@@ -73,7 +73,6 @@
 	struct tc_u_common	*tp_c;
 	int			refcnt;
 	unsigned		divisor;
-	u32			hgenerator;
 	struct tc_u_knode	*ht[1];
 };
 
