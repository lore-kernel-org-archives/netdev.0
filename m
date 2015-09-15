From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH for-next] cxgb4: add device ID for few T5 adapters
Date: Tue, 15 Sep 2015 17:20:09 +0530
Message-ID: <1442317809-7438-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31638 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751927AbbIOLts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 07:49:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index 8353a6c..03ed00c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -157,6 +157,11 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x5090),	/* Custom T540-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x5091),	/* Custom T522-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x5092),	/* Custom T520-CR */
+	CH_PCI_ID_TABLE_FENTRY(0x5093),	/* Custom T580-LP-CR */
+	CH_PCI_ID_TABLE_FENTRY(0x5094),	/* Custom T540-CR */
+	CH_PCI_ID_TABLE_FENTRY(0x5095),	/* Custom T540-CR-SO */
+	CH_PCI_ID_TABLE_FENTRY(0x5096),	/* Custom T580-CR */
+	CH_PCI_ID_TABLE_FENTRY(0x5097),	/* Custom T520-KR */
 
 	/* T6 adapters:
 	 */
-- 
2.3.4
