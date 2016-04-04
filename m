From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4: Add pci device id for chelsio t520-cr adapter
Date: Mon,  4 Apr 2016 09:54:53 +0530
Message-ID: <1459743893-577-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:59502 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750705AbcDDEVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 00:21:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index 06bc2d2e7a73..a2cdfc1261dc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -166,6 +166,7 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x5099),	/* Custom 2x40G QSFP */
 	CH_PCI_ID_TABLE_FENTRY(0x509a),	/* Custom T520-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x509b),	/* Custom T540-CR LOM */
+	CH_PCI_ID_TABLE_FENTRY(0x509c),	/* Custom T520-CR*/
 
 	/* T6 adapters:
 	 */
-- 
2.3.4
