From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: [PATCH] fix typo added in 2.6.0-test5
Date: Tue, 9 Sep 2003 00:00:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030909070002.GJ18862@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: coreteam@netfilter.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Trivial typo fix in just-changed code.

-Mitch

--- linux-2.6.0-test5-VIRGIN/net/ipv4/netfilter/ip_nat_tftp.c	2003-09-08 12:39:49.000000000 -0700
+++ linux-2.6.0-test5mnb1/net/ipv4/netfilter/ip_nat_tftp.c	2003-09-08 14:45:10.903081992 -0700
@@ -30,7 +30,7 @@
 #include <linux/netfilter_ipv4/ip_nat_rule.h>
 
 MODULE_AUTHOR("Magnus Boden <mb@ozaba.mine.nu>");
-MODULE_DESCRIPTION("tfpt NAT helper");
+MODULE_DESCRIPTION("tftp NAT helper");
 MODULE_LICENSE("GPL");
 
 #define MAX_PORTS 8
