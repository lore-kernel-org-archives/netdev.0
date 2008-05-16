From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 6/6] [BNX2]: Update version to 1.7.6.
Date: Fri, 16 May 2008 14:31:04 -0700
Message-ID: <1210973464.5507.22.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, benli@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4157 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752831AbYEPUiD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2008 16:38:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Update version to 1.7.6.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index e1787a1..b32d227 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -56,8 +56,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.7.5"
-#define DRV_MODULE_RELDATE	"April 29, 2008"
+#define DRV_MODULE_VERSION	"1.7.6"
+#define DRV_MODULE_RELDATE	"May 16, 2008"
 
 #define RUN_AT(x) (jiffies + (x))
 
-- 
1.5.5.GIT



