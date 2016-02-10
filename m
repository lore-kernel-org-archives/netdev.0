From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH] cxgb4: Add pci device id for chelsio t540 lom adapter
Date: Wed, 10 Feb 2016 12:28:49 +0530
Message-ID: <1455087529-23453-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, swise@opengridcomputing.com,
	nirranjan@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:2593 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751531AbcBJG4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 01:56:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index a8dda635456d..06bc2d2e7a73 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -165,6 +165,7 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x5098),	/* Custom 2x40G QSFP */
 	CH_PCI_ID_TABLE_FENTRY(0x5099),	/* Custom 2x40G QSFP */
 	CH_PCI_ID_TABLE_FENTRY(0x509a),	/* Custom T520-CR */
+	CH_PCI_ID_TABLE_FENTRY(0x509b),	/* Custom T540-CR LOM */
 
 	/* T6 adapters:
 	 */
-- 
2.3.4
