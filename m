From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: [net, 6/6] net: korina: version bump
Date: Tue, 17 Jan 2017 19:33:13 +0200
Message-ID: <1484674393-22515-1-git-send-email-roman@advem.lv>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36301 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751204AbdAQRmU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 12:42:20 -0500
Received: by mail-lf0-f66.google.com with SMTP id h65so17184758lfi.3
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 09:42:19 -0800 (PST)
Received: from ubrain.lan ([213.175.92.61])
        by smtp.googlemail.com with ESMTPSA id f17sm7207229ljb.13.2017.01.17.09.33.16
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 09:33:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 83c994f..c8fed01 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -66,8 +66,8 @@
 #include <asm/mach-rc32434/dma_v.h>
 
 #define DRV_NAME	"korina"
-#define DRV_VERSION	"0.10"
-#define DRV_RELDATE	"04Mar2008"
+#define DRV_VERSION	"0.20"
+#define DRV_RELDATE	"15Jan2017"
 
 #define STATION_ADDRESS_HIGH(dev) (((dev)->dev_addr[0] << 8) | \
 				   ((dev)->dev_addr[1]))
-- 
2.7.4
