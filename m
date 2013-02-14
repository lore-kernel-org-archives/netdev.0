From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 5/5 net-next] tg3: Update version to 3.130
Date: Thu, 14 Feb 2013 14:13:42 -0800
Message-ID: <1360880022-12856-5-git-send-email-mchan@broadcom.com>
References: <1360880022-12856-1-git-send-email-mchan@broadcom.com>
 <1360880022-12856-2-git-send-email-mchan@broadcom.com>
 <1360880022-12856-3-git-send-email-mchan@broadcom.com>
 <1360880022-12856-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4443 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934966Ab3BNV4b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 16:56:31 -0500
In-Reply-To: <1360880022-12856-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 3829321..1b59876 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -94,10 +94,10 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 
 #define DRV_MODULE_NAME		"tg3"
 #define TG3_MAJ_NUM			3
-#define TG3_MIN_NUM			129
+#define TG3_MIN_NUM			130
 #define DRV_MODULE_VERSION	\
 	__stringify(TG3_MAJ_NUM) "." __stringify(TG3_MIN_NUM)
-#define DRV_MODULE_RELDATE	"January 06, 2013"
+#define DRV_MODULE_RELDATE	"February 14, 2013"
 
 #define RESET_KIND_SHUTDOWN	0
 #define RESET_KIND_INIT		1
-- 
1.7.1
