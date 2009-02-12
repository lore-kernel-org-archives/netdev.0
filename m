From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 35/41]bnx2x: Removing unused struct
Date: Thu, 12 Feb 2009 20:38:20 +0200
Message-ID: <1234463900.1863.167.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Harvey Harrison" <harvey.harrison@gmail.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1667 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759060AbZBLSpL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:45:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 35/41]bnx2x: Removing unused struct

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_hsi.h |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index c779999..51c5fe1 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -2238,16 +2238,6 @@ union eth_ramrod_data {
 
 
 /*
- * Rx Last BD in page (in ETH)
- */
-struct eth_rx_bd_next_page {
-	u32 addr_lo;
-	u32 addr_hi;
-	u8 reserved[8];
-};
-
-
-/*
  * Eth Rx Cqe structure- general structure for ramrods
  */
 struct common_ramrod_eth_rx_cqe {
-- 
1.5.4.3




