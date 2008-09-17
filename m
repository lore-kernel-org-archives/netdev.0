From: "Benjamin Li" <benli@broadcom.com>
Subject: [NET-NEXT PATCH] bnx2: Update MODULE_DESCRIPTION to include the
 5716
Date: Wed, 17 Sep 2008 16:02:19 -0700
Message-ID: <e5dd28099c48ea622c1ec67bce736dba9a139a20.1219454143.git.benli@broadcom.com>
References: <cover.1219454143.git.benli@broadcom.com>
 <a93511dbe76cb994f3dbd16c3ad820617d4187e9.1219454143.git.benli@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benli@broadcom.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2971 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755067AbYIQXCb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Sep 2008 19:02:31 -0400
Received: from mail-irva-8.broadcom.com (mail-irva-8 [10.11.18.52]) by
 mail-irva-10.broadcom.com (Postfix) with ESMTP id CECEA2B0 for
 <netdev@vger.kernel.org>; Wed, 17 Sep 2008 16:02:24 -0700 (PDT)
In-Reply-To: <a93511dbe76cb994f3dbd16c3ad820617d4187e9.1219454143.git.benli@broadcom.com>
In-Reply-To: <cover.1219454143.git.benli@broadcom.com>
References: <cover.1219454143.git.benli@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 192a24e..a78b664 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -69,7 +69,7 @@ static char version[] __devinitdata =
 	"Broadcom NetXtreme II Gigabit Ethernet Driver " DRV_MODULE_NAME " v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
 MODULE_AUTHOR("Michael Chan <mchan@broadcom.com>");
-MODULE_DESCRIPTION("Broadcom NetXtreme II BCM5706/5708/5709 Driver");
+MODULE_DESCRIPTION("Broadcom NetXtreme II BCM5706/5708/5709/5716 Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
 
-- 
1.5.6.4


