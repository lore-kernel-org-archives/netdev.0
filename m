From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next v2 6/6] fjes: Update fjes driver version : 1.2
Date: Fri, 14 Oct 2016 20:28:15 +0900
Message-ID: <1476444495-28942-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1476444345-28673-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm03.jp.fujitsu.com ([202.219.69.170]:14756 "EHLO
        mgwkm03.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754310AbcJNLjV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 07:39:21 -0400
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
        by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 3E7B9AC01F1
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 20:39:15 +0900 (JST)
In-Reply-To: <1476444345-28673-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 359e7a5..f36eb4a 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -30,7 +30,7 @@
 #include "fjes_trace.h"
 
 #define MAJ 1
-#define MIN 1
+#define MIN 2
 #define DRV_VERSION __stringify(MAJ) "." __stringify(MIN)
 #define DRV_NAME	"fjes"
 char fjes_driver_name[] = DRV_NAME;
-- 
2.6.6
