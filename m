From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net 7/7] bnx2x: update driver version to 1.70.30-0
Date: Wed, 26 Oct 2011 11:40:39 +0200
Message-ID: <1319622039-10553-8-git-send-email-yanivr@broadcom.com>
References: <1319622039-10553-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2931 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754778Ab1JZHlU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Oct 2011 03:41:20 -0400
In-Reply-To: <1319622039-10553-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 9a7eb3b..54975a2 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -23,8 +23,8 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.70.00-0"
-#define DRV_MODULE_RELDATE      "2011/06/13"
+#define DRV_MODULE_VERSION      "1.70.30-0"
+#define DRV_MODULE_RELDATE      "2011/10/25"
 #define BNX2X_BC_VER            0x040200
 
 #if defined(CONFIG_DCB)
-- 
1.7.7.1
