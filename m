From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 4/4] bnx2: Update version to 2.0.17.
Date: Mon, 19 Jul 2010 17:15:05 -0700
Message-ID: <1279584905-15084-4-git-send-email-mchan@broadcom.com>
References: <1279584905-15084-1-git-send-email-mchan@broadcom.com>
 <1279584905-15084-2-git-send-email-mchan@broadcom.com>
 <1279584905-15084-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2774 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757653Ab0GTAMB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jul 2010 20:12:01 -0400
In-Reply-To: <1279584905-15084-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 2af570d..e6a803f 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -58,8 +58,8 @@
 #include "bnx2_fw.h"
 
 #define DRV_MODULE_NAME		"bnx2"
-#define DRV_MODULE_VERSION	"2.0.16"
-#define DRV_MODULE_RELDATE	"July 2, 2010"
+#define DRV_MODULE_VERSION	"2.0.17"
+#define DRV_MODULE_RELDATE	"July 18, 2010"
 #define FW_MIPS_FILE_06		"bnx2/bnx2-mips-06-5.0.0.j6.fw"
 #define FW_RV2P_FILE_06		"bnx2/bnx2-rv2p-06-5.0.0.j3.fw"
 #define FW_MIPS_FILE_09		"bnx2/bnx2-mips-09-5.0.0.j15.fw"
-- 
1.6.4.GIT


