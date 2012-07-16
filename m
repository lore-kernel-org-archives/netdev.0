From: Duan Jiong <djduanjiong@gmail.com>
Subject: [PATCH] lpc_eth: remove duplicated include
Date: Mon, 16 Jul 2012 17:48:18 +0800
Message-ID: <5003E362.4060604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:56578 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542Ab2GPJsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 05:48:24 -0400
Received: by ghrr11 with SMTP id r11so4786080ghr.19
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 02:48:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


---
 drivers/net/ethernet/nxp/lpc_eth.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 083d671..a1fe179 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -44,7 +44,6 @@
 #include <linux/of_net.h>
 #include <linux/types.h>
 
-#include <linux/delay.h>
 #include <linux/io.h>
 #include <mach/board.h>
 #include <mach/platform.h>
-- 
1.7.9.5
