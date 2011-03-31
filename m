From: Pan Weiping <panweiping3@gmail.com>
Subject: [PATCH 2/3] bonding:typo in comment
Date: Thu, 31 Mar 2011 14:46:19 +0800
Message-ID: <1301553980-29096-1-git-send-email-panweiping3@gmail.com>
Cc: Pan Weiping <panweiping3@gmail.com>,
	Jay Vosburgh <fubar@us.ibm.com> (supporter:BONDING DRIVER),
	Andy Gospodarek <andy@greyhouse.net> (supporter:BONDING DRIVER),
	netdev@vger.kernel.org (open list:BONDING DRIVER),
	linux-kernel@vger.kernel.org (open list)
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61895 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932720Ab1CaGpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 02:45:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use accumulates instead of acumulates.
Signed-off-by: Pan Weiping <panweiping3@gmail.com>
---
 drivers/net/bonding/bond_alb.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index 118c28a..4b3e358 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -74,7 +74,7 @@ struct tlb_client_info {
 				 * packets to a Client that the Hash function
 				 * gave this entry index.
 				 */
-	u32 tx_bytes;		/* Each Client acumulates the BytesTx that
+	u32 tx_bytes;		/* Each Client accumulates the BytesTx that
 				 * were tranmitted to it, and after each
 				 * CallBack the LoadHistory is devided
 				 * by the balance interval
-- 
1.7.4

