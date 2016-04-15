From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next v2 6/6] fjes: Update fjes driver version : 1.1
Date: Fri, 15 Apr 2016 11:25:52 +0900
Message-ID: <1460687152-26791-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1460686800-26427-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: jiri@resnulli.us, isimatu.yasuaki@jp.fujitsu.com,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym02.jp.fujitsu.com ([211.128.242.41]:26595 "EHLO
	mgwym02.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753079AbcDOCeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 22:34:22 -0400
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by yt-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id A85E3AC0132
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 11:34:16 +0900 (JST)
In-Reply-To: <1460686800-26427-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 87b2474..bb7e903 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -29,7 +29,7 @@
 #include "fjes.h"
 
 #define MAJ 1
-#define MIN 0
+#define MIN 1
 #define DRV_VERSION __stringify(MAJ) "." __stringify(MIN)
 #define DRV_NAME	"fjes"
 char fjes_driver_name[] = DRV_NAME;
-- 
2.4.3
