From: "Benjamin Li" <benli@broadcom.com>
Subject: [PATCH 4/4] bnx2: Update version to 1.7.9.
Date: Fri, 18 Jul 2008 14:20:50 -0700
Message-ID: <1216416050-10572-5-git-send-email-benli@broadcom.com>
References: <1216416050-10572-1-git-send-email-benli@broadcom.com>
 <1216416050-10572-2-git-send-email-benli@broadcom.com>
 <1216416050-10572-3-git-send-email-benli@broadcom.com>
 <1216416050-10572-4-git-send-email-benli@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benli@broadcom.com, "Michael Chan" <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1872 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754075AbYGRVVF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 17:21:05 -0400
Received: from mail-irva-8.broadcom.com (mail-irva-8 [10.11.18.52]) by
 mail-irva-10.broadcom.com (Postfix) with ESMTP id 2C48B2B0 for
 <netdev@vger.kernel.org>; Fri, 18 Jul 2008 14:20:52 -0700 (PDT)
In-Reply-To: <1216416050-10572-4-git-send-email-benli@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index c065499..5ebde67 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -57,8 +57,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.7.8"
-#define DRV_MODULE_RELDATE	"July 10, 2008"
+#define DRV_MODULE_VERSION	"1.7.9"
+#define DRV_MODULE_RELDATE	"July 18, 2008"
 
 #define RUN_AT(x) (jiffies + (x))
 
-- 
1.5.6.1


