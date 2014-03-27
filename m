From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH 2/2] cxgb4vf: Adds device Id for few more Chelsio adapters
Date: Thu, 27 Mar 2014 18:17:10 +0530
Message-ID: <1395924430-17632-3-git-send-email-hariprasad@chelsio.com>
References: <1395924430-17632-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, dm@chelsio.com, leedom@chelsio.com,
	kumaras@chelsio.com, santosh@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11130 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753943AbaC0Mzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 08:55:31 -0400
In-Reply-To: <1395924430-17632-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 1d0fe9b..5285928 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2944,6 +2944,14 @@ static DEFINE_PCI_DEVICE_TABLE(cxgb4vf_pci_tbl) = {
 	CH_DEVICE(0x5811, 0),   /* T520-lp-cr */
 	CH_DEVICE(0x5812, 0),   /* T560-cr */
 	CH_DEVICE(0x5813, 0),   /* T580-cr */
+	CH_DEVICE(0x5814, 0),   /* T580-so-cr */
+	CH_DEVICE(0x5815, 0),   /* T502-bt */
+	CH_DEVICE(0x5880, 0),
+	CH_DEVICE(0x5881, 0),
+	CH_DEVICE(0x5882, 0),
+	CH_DEVICE(0x5883, 0),
+	CH_DEVICE(0x5884, 0),
+	CH_DEVICE(0x5885, 0),
 	{ 0, }
 };
 
-- 
1.8.4
