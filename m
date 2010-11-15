From: Joe Perches <joe@perches.com>
Subject: [PATCH 16/44] drivers/net/wireless/ath: Remove unnecessary semicolons
Date: Sun, 14 Nov 2010 19:04:35 -0800
Message-ID: <c375cdc1175018f00066e2220f1d659ca70cde16.1289789604.git.joe@perches.com>
References: <cover.1289789604.git.joe@perches.com>
Cc: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Jouni Malinen <jmalinen@atheros.com>,
	Vasanthakumar Thiagarajan <vasanth@atheros.com>,
	Senthil Balasubramanian <senthilkumar@atheros.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1289789604.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath9k/htc.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/htc.h b/drivers/net/wireless/ath/ath9k/htc.h
index 75ecf6a..4c98b93 100644
--- a/drivers/net/wireless/ath/ath9k/htc.h
+++ b/drivers/net/wireless/ath/ath9k/htc.h
@@ -434,7 +434,7 @@ void ath9k_htc_beaconep(void *drv_priv, struct sk_buff *skb,
 
 void ath9k_htc_station_work(struct work_struct *work);
 void ath9k_htc_aggr_work(struct work_struct *work);
-void ath9k_ani_work(struct work_struct *work);;
+void ath9k_ani_work(struct work_struct *work);
 
 int ath9k_tx_init(struct ath9k_htc_priv *priv);
 void ath9k_tx_tasklet(unsigned long data);
-- 
1.7.3.1.g432b3.dirty
