From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 21/22] net-next: mediatek: change my email address
Date: Mon,  9 May 2016 12:04:13 +0200
Message-ID: <1462788254-40572-22-git-send-email-john@phrozen.org>
References: <1462788254-40572-1-git-send-email-john@phrozen.org>
Cc: nbd@nbd.name, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, John Crispin <john@phrozen.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:51991 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751420AbcEIKms (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 06:42:48 -0400
In-Reply-To: <1462788254-40572-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The old address is no longer valid. Use the my new one instead.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 74cb234..32bf54e 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -7,7 +7,7 @@
  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *   GNU General Public License for more details.
  *
- *   Copyright (C) 2009-2016 John Crispin <blogic@openwrt.org>
+ *   Copyright (C) 2009-2016 John Crispin <john@phrozen.org>
  *   Copyright (C) 2009-2016 Felix Fietkau <nbd@openwrt.org>
  *   Copyright (C) 2013-2016 Michael Lee <igvtee@gmail.com>
  */
@@ -1915,5 +1915,5 @@ static struct platform_driver mtk_driver = {
 module_platform_driver(mtk_driver);
 
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR("John Crispin <blogic@openwrt.org>");
+MODULE_AUTHOR("John Crispin <john@phrozen.org>");
 MODULE_DESCRIPTION("Ethernet driver for MediaTek SoC");
-- 
1.7.10.4
