From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/2] cxgb4: Add device ID for new adapter
Date: Thu, 19 Mar 2015 22:27:35 +0530
Message-ID: <1426784256-5689-2-git-send-email-hariprasad@chelsio.com>
References: <1426784256-5689-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:21281 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751202AbbCSQwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 12:52:09 -0400
In-Reply-To: <1426784256-5689-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index ddfb5b8..ee877c0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -154,6 +154,7 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x5087),	/* Custom T580-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x5088),	/* Custom T570-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x5089),	/* Custom T520-CR */
+	CH_PCI_ID_TABLE_FENTRY(0x5090),	/* Custom T540-CR */
 CH_PCI_DEVICE_ID_TABLE_DEFINE_END;
 
 #endif /* CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN */
-- 
1.7.1
