From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 4/4] bnx2: Update version to 2.2.5.
Date: Tue, 31 Dec 2013 23:22:35 -0800
Message-ID: <1388560955-32586-5-git-send-email-mchan@broadcom.com>
References: <1388560955-32586-1-git-send-email-mchan@broadcom.com>
 <1388560955-32586-2-git-send-email-mchan@broadcom.com>
 <1388560955-32586-3-git-send-email-mchan@broadcom.com>
 <1388560955-32586-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:52675 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656AbaAAG6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 01:58:49 -0500
In-Reply-To: <1388560955-32586-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 3fcabd9..3f3cae2 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -58,8 +58,8 @@
 #include "bnx2_fw.h"
 
 #define DRV_MODULE_NAME		"bnx2"
-#define DRV_MODULE_VERSION	"2.2.4"
-#define DRV_MODULE_RELDATE	"Aug 05, 2013"
+#define DRV_MODULE_VERSION	"2.2.5"
+#define DRV_MODULE_RELDATE	"December 20, 2013"
 #define FW_MIPS_FILE_06		"bnx2/bnx2-mips-06-6.2.3.fw"
 #define FW_RV2P_FILE_06		"bnx2/bnx2-rv2p-06-6.0.15.fw"
 #define FW_MIPS_FILE_09		"bnx2/bnx2-mips-09-6.2.1b.fw"
-- 
1.7.1
