From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next 11/11] fjes: Update fjes driver version : 1.1
Date: Mon, 11 Apr 2016 17:10:57 +0900
Message-ID: <1460362257-15466-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm01.jp.fujitsu.com ([202.219.69.168]:60089 "EHLO
	mgwkm01.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753588AbcDKITY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 04:19:24 -0400
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 3CE55AC01E3
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 17:19:14 +0900 (JST)
In-Reply-To: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 22bd175..bfd58cc 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -30,7 +30,7 @@
 #include "fjes_ioctl.h"
 
 #define MAJ 1
-#define MIN 0
+#define MIN 1
 #define DRV_VERSION __stringify(MAJ) "." __stringify(MIN)
 #define DRV_NAME	"fjes"
 char fjes_driver_name[] = DRV_NAME;
-- 
2.4.3
