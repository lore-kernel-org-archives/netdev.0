From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2.6] U32: Remove unused hgenerator field in tc_u_hnode
Date: Sat, 23 Oct 2004 00:10:20 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022221020.GG21977@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-bk6.orig/net/sched/cls_u32.c	2004-10-21 17:29:02.000000000 +0200
+++ linux-2.6.9-bk6/net/sched/cls_u32.c	2004-10-23 00:01:29.000000000 +0200
@@ -88,7 +88,6 @@
 	struct tc_u_common	*tp_c;
 	int			refcnt;
 	unsigned		divisor;
-	u32			hgenerator;
 	struct tc_u_knode	*ht[1];
 };
 
