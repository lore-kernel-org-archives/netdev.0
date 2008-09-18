From: "Benjamin Li" <benli@broadcom.com>
Subject: [UPDATED][NET-NEXT PATCH 2/4] bnx2: Update MODULE_DESCRIPTION
 to include the 5716
Date: Thu, 18 Sep 2008 09:57:11 -0700
Message-ID: <1221757033-4874-3-git-send-email-benli@broadcom.com>
References: <20080918063933.GA8027@verge.net.au>
 <1221757033-4874-1-git-send-email-benli@broadcom.com>
 <1221757033-4874-2-git-send-email-benli@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benli@broadcom.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1193 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756435AbYIRQ5Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2008 12:57:25 -0400
In-Reply-To: <1221757033-4874-2-git-send-email-benli@broadcom.com>
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
1.6.0.1


