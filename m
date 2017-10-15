From: Roman Yeryomin <roman@advem.lv>
Subject: [PATCH net-next 10/10] net: korina: bump version
Date: Sun, 15 Oct 2017 19:24:30 +0300
Message-ID: <20171015162430.1238-1-roman@advem.lv>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1l1v.rtu.lv ([213.175.92.62]:52646 "EHLO mail.pbx.lv"
        rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
        id S1751502AbdJOQdK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Oct 2017 12:33:10 -0400
Received: from ubrain.corp.ubnt.com (unknown [213.175.92.61])
        by mail.pbx.lv (MailSystem) with ESMTPSA id 70A60191956
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 19:23:51 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 8fa60d1fe022..fc8e80487507 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -66,8 +66,8 @@
 #include <asm/mach-rc32434/dma_v.h>
 
 #define DRV_NAME	"korina"
-#define DRV_VERSION	"0.20"
-#define DRV_RELDATE	"15Sep2017"
+#define DRV_VERSION	"0.21"
+#define DRV_RELDATE	"15Oct2017"
 
 #define STATION_ADDRESS_HIGH(dev) (((dev)->dev_addr[0] << 8) | \
 				   ((dev)->dev_addr[1]))
-- 
2.11.0
