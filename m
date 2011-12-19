From: Vinson Lee <vlee@vmware.com>
Subject: [PATCH] myri10ge: Fix typo of 'VMware' in comment.
Date: Mon, 19 Dec 2011 12:17:55 -0800
Message-ID: <1324325875-30907-1-git-send-email-vlee@vmware.com>
Cc: vlee@vmware.com, trivial@kernel.org
To: mason@myri.com, gallatin@myri.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Vinson Lee <vlee@vmware.com>
---
 .../net/ethernet/myricom/myri10ge/myri10ge_mcp.h   |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge_mcp.h b/drivers/net/ethernet/myricom/myri10ge/myri10ge_mcp.h
index 11be150..b7fc26c 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge_mcp.h
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge_mcp.h
@@ -356,7 +356,7 @@ enum myri10ge_mcp_cmd_type {
 	MXGEFW_CMD_GET_DCA_OFFSET = 56,
 	/* offset of dca control for WDMAs */
 
-	/* VMWare NetQueue commands */
+	/* VMware NetQueue commands */
 	MXGEFW_CMD_NETQ_GET_FILTERS_PER_QUEUE = 57,
 	MXGEFW_CMD_NETQ_ADD_FILTER = 58,
 	/* data0 = filter_id << 16 | queue << 8 | type */
-- 
1.7.1
