From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH -next 8/8] bnx2: Update version to 2.0.2.
Date: Fri, 21 Aug 2009 19:20:50 -0700
Message-ID: <1250907650-24672-8-git-send-email-mchan@broadcom.com>
References: <1250907650-24672-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2877 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933153AbZHVCNr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2009 22:13:47 -0400
In-Reply-To: <1250907650-24672-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 58ab3f4..4450177 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -59,8 +59,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"2.0.1"
-#define DRV_MODULE_RELDATE	"May 6, 2009"
+#define DRV_MODULE_VERSION	"2.0.2"
+#define DRV_MODULE_RELDATE	"Aug 21, 2009"
 #define FW_MIPS_FILE_06		"bnx2/bnx2-mips-06-4.6.16.fw"
 #define FW_RV2P_FILE_06		"bnx2/bnx2-rv2p-06-4.6.16.fw"
 #define FW_MIPS_FILE_09		"bnx2/bnx2-mips-09-4.6.17.fw"
-- 
1.5.6.GIT


