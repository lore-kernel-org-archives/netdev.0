From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 5/5] bnx2: Update version to 2.0.3.
Date: Thu, 3 Dec 2009 11:46:35 -0800
Message-ID: <1259869595-6450-5-git-send-email-mchan@broadcom.com>
References: <1259869595-6450-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4590 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754135AbZLCTjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 14:39:23 -0500
In-Reply-To: <1259869595-6450-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index b7bc74b..cf4322d 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -59,8 +59,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"2.0.2"
-#define DRV_MODULE_RELDATE	"Aug 21, 2009"
+#define DRV_MODULE_VERSION	"2.0.3"
+#define DRV_MODULE_RELDATE	"Dec 03, 2009"
 #define FW_MIPS_FILE_06		"bnx2/bnx2-mips-06-5.0.0.j3.fw"
 #define FW_RV2P_FILE_06		"bnx2/bnx2-rv2p-06-5.0.0.j3.fw"
 #define FW_MIPS_FILE_09		"bnx2/bnx2-mips-09-5.0.0.j3.fw"
-- 
1.6.4.GIT


