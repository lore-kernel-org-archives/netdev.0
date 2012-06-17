From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 4/4] bnx2: Update version 2.2.2
Date: Sat, 16 Jun 2012 18:45:44 -0700
Message-ID: <1339897544-20254-4-git-send-email-mchan@broadcom.com>
References: <1339897544-20254-1-git-send-email-mchan@broadcom.com>
 <1339897544-20254-2-git-send-email-mchan@broadcom.com>
 <1339897544-20254-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4107 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755332Ab2FQBl6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Jun 2012 21:41:58 -0400
In-Reply-To: <1339897544-20254-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index c6d3943..9b69a62 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -58,8 +58,8 @@
 #include "bnx2_fw.h"
 
 #define DRV_MODULE_NAME		"bnx2"
-#define DRV_MODULE_VERSION	"2.2.1"
-#define DRV_MODULE_RELDATE	"Dec 18, 2011"
+#define DRV_MODULE_VERSION	"2.2.2"
+#define DRV_MODULE_RELDATE	"June 16, 2012"
 #define FW_MIPS_FILE_06		"bnx2/bnx2-mips-06-6.2.3.fw"
 #define FW_RV2P_FILE_06		"bnx2/bnx2-rv2p-06-6.0.15.fw"
 #define FW_MIPS_FILE_09		"bnx2/bnx2-mips-09-6.2.1b.fw"
-- 
1.7.1
