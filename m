From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH] net: vxge: fix typo argumnet argument
Date: Sat, 25 Feb 2017 21:08:57 +0100
Message-ID: <20170225200857.26749-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: jdmason@kudzu.us
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit fix the typo argumnet/argument

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/neterion/vxge/vxge-ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-ethtool.c b/drivers/net/ethernet/neterion/vxge/vxge-ethtool.c
index db55e6d..0452848 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-ethtool.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-ethtool.c
@@ -119,7 +119,7 @@ static void vxge_ethtool_gdrvinfo(struct net_device *dev,
  * @dev: device pointer.
  * @regs: pointer to the structure with parameters given by ethtool for
  * dumping the registers.
- * @reg_space: The input argumnet into which all the registers are dumped.
+ * @reg_space: The input argument into which all the registers are dumped.
  *
  * Dumps the vpath register space of Titan NIC into the user given
  * buffer area.
-- 
2.10.2
