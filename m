From: weiyj_lk@163.com
Subject: [PATCH -next] dwc_eth_qos: remove unused including <linux/version.h>
Date: Mon,  4 Jul 2016 15:24:50 +0000
Message-ID: <1467645890-12766-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, netdev@vger.kernel.org
To: Lars Persson <lars.persson@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-18.163.com ([220.181.12.18]:50061 "EHLO m12-18.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753427AbcGDPZC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2016 11:25:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>

Remove including <linux/version.h> that don't need it.

Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index c14fa91..c34111b 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -46,7 +46,6 @@
 #include <linux/delay.h>
 #include <linux/dma-mapping.h>
 #include <linux/vmalloc.h>
-#include <linux/version.h>
 
 #include <linux/device.h>
 #include <linux/bitrev.h>
