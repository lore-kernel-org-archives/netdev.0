From: Nithin Nayak Sujir <nsujir@broadcom.com>
Subject: [PATCH net-next 5/5] tg3: Update version to 3.135
Date: Fri, 6 Dec 2013 09:53:20 -0800
Message-ID: <1386352400-9623-6-git-send-email-nsujir@broadcom.com>
References: <1386352400-9623-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:34927 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758208Ab3LFRxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 12:53:32 -0500
In-Reply-To: <1386352400-9623-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 7cba139..9a4a601 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -94,10 +94,10 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 
 #define DRV_MODULE_NAME		"tg3"
 #define TG3_MAJ_NUM			3
-#define TG3_MIN_NUM			134
+#define TG3_MIN_NUM			135
 #define DRV_MODULE_VERSION	\
 	__stringify(TG3_MAJ_NUM) "." __stringify(TG3_MIN_NUM)
-#define DRV_MODULE_RELDATE	"Sep 16, 2013"
+#define DRV_MODULE_RELDATE	"Nov 14, 2013"
 
 #define RESET_KIND_SHUTDOWN	0
 #define RESET_KIND_INIT		1
-- 
1.8.1.4
