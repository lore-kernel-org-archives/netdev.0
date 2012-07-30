From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net 5/5] tg3: Update version to 3.124
Date: Sun, 29 Jul 2012 22:15:45 -0700
Message-ID: <1343625345-5155-5-git-send-email-mchan@broadcom.com>
References: <1343625345-5155-1-git-send-email-mchan@broadcom.com>
 <1343625345-5155-2-git-send-email-mchan@broadcom.com>
 <1343625345-5155-3-git-send-email-mchan@broadcom.com>
 <1343625345-5155-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2423 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754014Ab2G3FDt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2012 01:03:49 -0400
In-Reply-To: <1343625345-5155-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index f03614b..bf906c5 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -92,7 +92,7 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 
 #define DRV_MODULE_NAME		"tg3"
 #define TG3_MAJ_NUM			3
-#define TG3_MIN_NUM			123
+#define TG3_MIN_NUM			124
 #define DRV_MODULE_VERSION	\
 	__stringify(TG3_MAJ_NUM) "." __stringify(TG3_MIN_NUM)
 #define DRV_MODULE_RELDATE	"March 21, 2012"
-- 
1.7.1
