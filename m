From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v5 01/11] net: mvmdio: reorder headers alphabetically
Date: Thu, 15 Jun 2017 16:43:16 +0200
Message-ID: <20170615144326.24463-2-antoine.tenart@free-electrons.com>
References: <20170615144326.24463-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:34829 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752654AbdFOOoG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 10:44:06 -0400
In-Reply-To: <20170615144326.24463-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cosmetic fix reordering headers alphabetically.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/marvell/mvmdio.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 90a60b98c28e..109a2bff334d 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -17,16 +17,16 @@
  * warranty of any kind, whether express or implied.
  */
 
+#include <linux/clk.h>
+#include <linux/delay.h>
+#include <linux/interrupt.h>
+#include <linux/io.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/mutex.h>
+#include <linux/of_mdio.h>
 #include <linux/phy.h>
-#include <linux/interrupt.h>
 #include <linux/platform_device.h>
-#include <linux/delay.h>
-#include <linux/io.h>
-#include <linux/clk.h>
-#include <linux/of_mdio.h>
 #include <linux/sched.h>
 #include <linux/wait.h>
 
-- 
2.9.4
