From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/3] bnx2: Update version to 2.0.9.
Date: Tue, 27 Apr 2010 14:28:11 -0700
Message-ID: <1272403691-2934-3-git-send-email-mchan@broadcom.com>
References: <1272403691-2934-1-git-send-email-mchan@broadcom.com>
 <1272403691-2934-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, jfeeney@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4073 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756030Ab0D0VRH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 17:17:07 -0400
In-Reply-To: <1272403691-2934-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 35eec2d..ac90a38 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -58,8 +58,8 @@
 #include "bnx2_fw.h"
 
 #define DRV_MODULE_NAME		"bnx2"
-#define DRV_MODULE_VERSION	"2.0.8"
-#define DRV_MODULE_RELDATE	"Feb 15, 2010"
+#define DRV_MODULE_VERSION	"2.0.9"
+#define DRV_MODULE_RELDATE	"April 27, 2010"
 #define FW_MIPS_FILE_06		"bnx2/bnx2-mips-06-5.0.0.j6.fw"
 #define FW_RV2P_FILE_06		"bnx2/bnx2-rv2p-06-5.0.0.j3.fw"
 #define FW_MIPS_FILE_09		"bnx2/bnx2-mips-09-5.0.0.j9.fw"
-- 
1.6.4.GIT


