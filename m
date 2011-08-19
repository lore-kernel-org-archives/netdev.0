From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 6/6] tg3: Update version to 3.120
Date: Fri, 19 Aug 2011 16:58:24 -0700
Message-ID: <1313798304-26171-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2636 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756576Ab1HSXu7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Aug 2011 19:50:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the tg3 version to 3.120.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index eb3b5ce..b3251dc 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -89,10 +89,10 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 
 #define DRV_MODULE_NAME		"tg3"
 #define TG3_MAJ_NUM			3
-#define TG3_MIN_NUM			119
+#define TG3_MIN_NUM			120
 #define DRV_MODULE_VERSION	\
 	__stringify(TG3_MAJ_NUM) "." __stringify(TG3_MIN_NUM)
-#define DRV_MODULE_RELDATE	"May 18, 2011"
+#define DRV_MODULE_RELDATE	"August 18, 2011"
 
 #define TG3_DEF_RX_MODE		0
 #define TG3_DEF_TX_MODE		0
-- 
1.7.3.4


