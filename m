From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 2/2] tg3: Update version to 3.132
Date: Tue, 21 May 2013 15:57:33 -0700
Message-ID: <1369177053-7117-3-git-send-email-nsujir@broadcom.com>
References: <1369177053-7117-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3128 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753182Ab3EUW5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 18:57:42 -0400
In-Reply-To: <1369177053-7117-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 6ba031b..2302a44 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -94,10 +94,10 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 
 #define DRV_MODULE_NAME		"tg3"
 #define TG3_MAJ_NUM			3
-#define TG3_MIN_NUM			131
+#define TG3_MIN_NUM			132
 #define DRV_MODULE_VERSION	\
 	__stringify(TG3_MAJ_NUM) "." __stringify(TG3_MIN_NUM)
-#define DRV_MODULE_RELDATE	"April 09, 2013"
+#define DRV_MODULE_RELDATE	"May 21, 2013"
 
 #define RESET_KIND_SHUTDOWN	0
 #define RESET_KIND_INIT		1
-- 
1.8.1.4
