From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH] trivial speeling fix in net/sched/Kconfig
Date: Thu, 21 Oct 2004 18:43:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021184320.K2357@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Trivial speeling fixes.

Signed-off-by: Chris Wright <chrisw@osdl.org>

===== net/sched/Kconfig 1.22 vs edited =====
--- 1.22/net/sched/Kconfig	2004-10-19 21:45:22 -07:00
+++ edited/net/sched/Kconfig	2004-10-21 18:34:57 -07:00
@@ -391,14 +391,14 @@
         tristate "generic Actions"
         depends on NET_CLS_ACT
         ---help---
-        You must have new iproute2 to use this feature
-        This adds simple filtering actions like drop,accepet etc 
+        You must have new iproute2 to use this feature.
+        This adds simple filtering actions like drop, accept etc.
                                                                                 
 config GACT_PROB
         bool "generic Actions probability"
         depends on NET_ACT_GACT
         ---help---
-        Allows generic actions to be randomly  or deterministically used
+        Allows generic actions to be randomly or deterministically used.
 
 config NET_ACT_MIRRED
         tristate "Packet In/Egress redirecton/mirror Actions"
