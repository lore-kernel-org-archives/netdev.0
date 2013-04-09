From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 10/11] tg3: Update version to 3.131
Date: Tue, 9 Apr 2013 11:48:10 -0700
Message-ID: <1365533291-5672-11-git-send-email-nsujir@broadcom.com>
References: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1181 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935376Ab3DISs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 14:48:58 -0400
In-Reply-To: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 2bd2213..0fe6444 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -94,10 +94,10 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 
 #define DRV_MODULE_NAME		"tg3"
 #define TG3_MAJ_NUM			3
-#define TG3_MIN_NUM			130
+#define TG3_MIN_NUM			131
 #define DRV_MODULE_VERSION	\
 	__stringify(TG3_MAJ_NUM) "." __stringify(TG3_MIN_NUM)
-#define DRV_MODULE_RELDATE	"February 14, 2013"
+#define DRV_MODULE_RELDATE	"April 09, 2013"
 
 #define RESET_KIND_SHUTDOWN	0
 #define RESET_KIND_INIT		1
-- 
1.8.1.4
