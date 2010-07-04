From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 4/4] bnx2: Update version to 2.0.16.
Date: Sat, 3 Jul 2010 23:42:18 -0700
Message-ID: <1278225738-7795-4-git-send-email-mchan@broadcom.com>
References: <1278225738-7795-1-git-send-email-mchan@broadcom.com>
 <1278225738-7795-2-git-send-email-mchan@broadcom.com>
 <1278225738-7795-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1335 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754605Ab0GDGjk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jul 2010 02:39:40 -0400
In-Reply-To: <1278225738-7795-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 1450c75..ae0a9af 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -58,8 +58,8 @@
 #include "bnx2_fw.h"
 
 #define DRV_MODULE_NAME		"bnx2"
-#define DRV_MODULE_VERSION	"2.0.15"
-#define DRV_MODULE_RELDATE	"May 4, 2010"
+#define DRV_MODULE_VERSION	"2.0.16"
+#define DRV_MODULE_RELDATE	"July 2, 2010"
 #define FW_MIPS_FILE_06		"bnx2/bnx2-mips-06-5.0.0.j6.fw"
 #define FW_RV2P_FILE_06		"bnx2/bnx2-rv2p-06-5.0.0.j3.fw"
 #define FW_MIPS_FILE_09		"bnx2/bnx2-mips-09-5.0.0.j15.fw"
-- 
1.6.4.GIT


