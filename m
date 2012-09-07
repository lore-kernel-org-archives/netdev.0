From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 1/10] drivers/net/wireless/ath/ath9k/ar9003_mac.c: removes unnecessary semicolon
Date: Fri,  7 Sep 2012 17:24:41 +0200
Message-ID: <1347031488-26598-3-git-send-email-peter.senna@gmail.com>
Cc: kernel-janitors@vger.kernel.org, Julia.Lawall@lip6.fr,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>,
	Senthil Balasubramanian <senthilb@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Senna Tschudin <peter.senna@gmail.com>

removes unnecessary semicolon

Found by Coccinelle: http://coccinelle.lip6.fr/

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

---
 drivers/net/wireless/ath/ath9k/ar9003_mac.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -u -p a/drivers/net/wireless/ath/ath9k/ar9003_mac.c b/drivers/net/wireless/ath/ath9k/ar9003_mac.c
--- a/drivers/net/wireless/ath/ath9k/ar9003_mac.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_mac.c
@@ -531,7 +531,7 @@ int ath9k_hw_process_rxdesc_edma(struct
 				rxs->rs_status |= ATH9K_RXERR_PHY;
 				rxs->rs_phyerr = phyerr;
 			}
-		};
+		}
 	}
 
 	if (rxsp->status11 & AR_KeyMiss)
