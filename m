From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH] net: s2io: fix typo argumnet argument
Date: Sat, 25 Feb 2017 21:12:41 +0100
Message-ID: <20170225201241.30251-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: jdmason@kudzu.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35291 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751929AbdBYUOs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Feb 2017 15:14:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit fix the typo argumnet/argument

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/neterion/s2io.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index c5c1d0e..118723e 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -5397,7 +5397,7 @@ static void s2io_ethtool_gdrvinfo(struct net_device *dev,
  *  s2io_nic structure.
  *  @regs : pointer to the structure with parameters given by ethtool for
  *  dumping the registers.
- *  @reg_space: The input argumnet into which all the registers are dumped.
+ *  @reg_space: The input argument into which all the registers are dumped.
  *  Description:
  *  Dumps the entire register space of xFrame NIC into the user given
  *  buffer area.
-- 
2.10.2
