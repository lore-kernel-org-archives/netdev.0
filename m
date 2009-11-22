From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: [PATCH] net: Fix missing kernel-doc notation
Date: Sun, 22 Nov 2009 13:49:06 +0530
Message-ID: <1258877946.4495.52.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Randy Dunlap <randy.dunlap@oracle.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754273AbZKVIUh@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Fix the following htmldocs warning:

  Warning(net/core/dev.c:5378): bad line:

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>
Cc: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 9977288..bd32d7a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5375,7 +5375,7 @@ EXPORT_SYMBOL(synchronize_net);
  *	unregister_netdevice_queue - remove device from the kernel
  *	@dev: device
  *	@head: list
-
+ *
  *	This function shuts down a device interface and removes it
  *	from the kernel tables.
  *	If head not NULL, device is queued to be unregistered later.
-- 
1.6.5.3
