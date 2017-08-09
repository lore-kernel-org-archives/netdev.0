From: John Crispin <john@phrozen.org>
Subject: [PATCH 1/2] net-next: mediatek: fix typos inside the header file
Date: Wed,  9 Aug 2017 12:09:31 +0200
Message-ID: <20170809100932.10539-2-john@phrozen.org>
References: <20170809100932.10539-1-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
        linux-kernel@vger.kernel.org, Muciri Gatimu <muciri@openmesh.com>,
        Shashidhar Lakkavalli <shashidhar.lakkavalli@openmesh.com>,
        John Crispin <john@phrozen.org>
To: "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170809100932.10539-1-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Trivial patch fixing 2 typos.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index 4594862e5a9b..940517af8039 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -599,8 +599,8 @@ struct mtk_soc_data {
  * @pctl:		The register map pointing at the range used to setup
  *			GMAC port drive/slew values
  * @dma_refcnt:		track how many netdevs are using the DMA engine
- * @tx_ring:		Pointer to the memore holding info about the TX ring
- * @rx_ring:		Pointer to the memore holding info about the RX ring
+ * @tx_ring:		Pointer to the memory holding info about the TX ring
+ * @rx_ring:		Pointer to the memory holding info about the RX ring
  * @tx_napi:		The TX NAPI struct
  * @rx_napi:		The RX NAPI struct
  * @scratch_ring:	Newer SoCs need memory for a second HW managed TX ring
-- 
2.11.0
