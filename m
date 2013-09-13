From: ZHAO Gang <gamerh2o@gmail.com>
Subject: [PATCH] [Trivial] remove unnecessary header file inclusion
Date: Fri, 13 Sep 2013 22:57:18 +0800
Message-ID: <20130913145718.GA2536@will>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: gamerh2o@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


file linux/fib_rules.h doesn't exist, so remove it.

Signed-off-by: ZHAO Gang <gamerh2o@gmail.com>
---
 include/net/fib_rules.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 4b2b557..c816f91 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -4,7 +4,6 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/netdevice.h>
-#include <linux/fib_rules.h>
 #include <net/flow.h>
 #include <net/rtnetlink.h>
 
-- 
1.8.3.1
