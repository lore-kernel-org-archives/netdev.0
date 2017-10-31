From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1] MAINTAINERS: Add lib/net_utils.c to NETWORKING (general)
Date: Tue, 31 Oct 2017 16:37:18 +0200
Message-ID: <20171031143718.35842-1-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It looks like the best place in MAINTAINERS data base to cover this
orphaned module.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 0630482e701b..474321873fc1 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9465,6 +9465,7 @@ F:	include/uapi/linux/net.h
 F:	include/uapi/linux/netdevice.h
 F:	include/uapi/linux/net_namespace.h
 F:	tools/testing/selftests/net/
+F:	lib/net_utils.c
 F:	lib/random32.c
 
 NETWORKING [IPSEC]
-- 
2.14.2
