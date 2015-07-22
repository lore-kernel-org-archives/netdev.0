From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 6/6] bnx2x: Bump up driver version to 1.712.30
Date: Wed, 22 Jul 2015 09:16:27 +0300
Message-ID: <1437545787-22097-7-git-send-email-Yuval.Mintz@qlogic.com>
References: <1437545787-22097-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:36410 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755877AbbGVGRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 02:17:18 -0400
In-Reply-To: <1437545787-22097-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 2fe3563..a1f9785 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -32,7 +32,7 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.710.51-0"
+#define DRV_MODULE_VERSION      "1.712.30-0"
 #define DRV_MODULE_RELDATE      "2014/02/10"
 #define BNX2X_BC_VER            0x040200
 
-- 
1.9.3
