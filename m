From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/4) bridge: get rid of unneeded include
Date: Thu, 10 Mar 2005 15:44:32 -0800
Message-ID: <20050310154432.1163ad2d@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bridge@lists.osdl.org
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Get rid of unneeded include.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


diff -Nru a/net/bridge/br.c b/net/bridge/br.c
--- a/net/bridge/br.c	2005-03-10 15:06:38 -08:00
+++ b/net/bridge/br.c	2005-03-10 15:06:38 -08:00
@@ -16,7 +16,6 @@
 #include <linux/config.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
-#include <linux/miscdevice.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/init.h>
