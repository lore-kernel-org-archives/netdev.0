From: Kusanagi Kouichi <slash@ac.auone-net.jp>
Subject: [PATCH] net: Fix a comment typo
Date: Mon, 18 Mar 2013 21:59:52 +0900
Message-ID: <20130318125952.CC5E615C03A@msa104.auone-net.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Jiri Kosina <trivial@kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Kusanagi Kouichi <slash@ac.auone-net.jp>
---
 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index dffbef7..69f696a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3326,7 +3326,7 @@ EXPORT_SYMBOL_GPL(netdev_rx_handler_register);
  *	netdev_rx_handler_unregister - unregister receive handler
  *	@dev: device to unregister a handler from
  *
- *	Unregister a receive hander from a device.
+ *	Unregister a receive handler from a device.
  *
  *	The caller must hold the rtnl_mutex.
  */
-- 
1.7.10.4
