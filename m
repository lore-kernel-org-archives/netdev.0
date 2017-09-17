From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: [PATCH net-next v2 7/7] net: korina: bump version
Date: Sun, 17 Sep 2017 20:25:21 +0300
Message-ID: <20170917172521.32639-1-roman@advem.lv>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:33385 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751686AbdIQRZW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 17 Sep 2017 13:25:22 -0400
Received: by mail-lf0-f65.google.com with SMTP id y15so3448600lfd.0
        for <netdev@vger.kernel.org>; Sun, 17 Sep 2017 10:25:21 -0700 (PDT)
Received: from ubrain.corp.ubnt.com ([2a02:16d8:105:4000:76d4:35ff:fe88:7631])
        by smtp.googlemail.com with ESMTPSA id p16sm1408181lja.74.2017.09.17.10.25.19
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Sep 2017 10:25:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index d58aa4bfcb58..7cecd9dbc111 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -66,8 +66,8 @@
 #include <asm/mach-rc32434/dma_v.h>
 
 #define DRV_NAME	"korina"
-#define DRV_VERSION	"0.10"
-#define DRV_RELDATE	"04Mar2008"
+#define DRV_VERSION	"0.20"
+#define DRV_RELDATE	"15Sep2017"
 
 #define STATION_ADDRESS_HIGH(dev) (((dev)->dev_addr[0] << 8) | \
 				   ((dev)->dev_addr[1]))
-- 
2.11.0
