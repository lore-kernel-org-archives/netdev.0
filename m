From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH v2 1/3] net: wireless: rsi: Coding Spaces
Date: Mon, 19 Oct 2015 17:02:21 +0100
Message-ID: <1445270543-2209-2-git-send-email-paulmcquad@gmail.com>
References: <1445270543-2209-1-git-send-email-paulmcquad@gmail.com>
Cc: kvalo@codeaurora.org, zajec5@gmail.com, davem@davemloft.net,
	joe@perches.com, johannes.berg@intel.com, sd@queasysnail.net,
	m@bues.ch, mike.looijmans@topic.nl, khoroshilov@ispras.ru,
	cengelma@gmx.at, linux-wireless@vger.kernel.org,
	b43-dev@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: paulmcquad@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445270543-2209-1-git-send-email-paulmcquad@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removed space before that ','

Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
---
 drivers/net/wireless/rsi/rsi_91x_sdio_ops.c | 2 +-
 drivers/net/wireless/rsi/rsi_mgmt.h         | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c b/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c
index 40d7231..8fa241b 100644
--- a/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c
+++ b/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c
@@ -435,7 +435,7 @@ void rsi_interrupt_handler(struct rsi_hw *adapter)
 				} else {
 					rsi_dbg(ERR_ZONE,
 						"%s: Firmware Status is 0x%x\n",
-						__func__ , fw_status);
+						__func__, fw_status);
 					rsi_sdio_ack_intr(common->priv,
 							  (1 << FW_ASSERT_IND));
 				}
diff --git a/drivers/net/wireless/rsi/rsi_mgmt.h b/drivers/net/wireless/rsi/rsi_mgmt.h
index 3741173..3d4eddd 100644
--- a/drivers/net/wireless/rsi/rsi_mgmt.h
+++ b/drivers/net/wireless/rsi/rsi_mgmt.h
@@ -173,9 +173,9 @@ enum cmd_frame_type {
 	AUTO_RATE_IND,
 	BOOTUP_PARAMS_REQUEST,
 	VAP_CAPABILITIES,
-	EEPROM_READ_TYPE ,
+	EEPROM_READ_TYPE,
 	EEPROM_WRITE,
-	GPIO_PIN_CONFIG ,
+	GPIO_PIN_CONFIG,
 	SET_RX_FILTER,
 	AMPDU_IND,
 	STATS_REQUEST_FRAME,
-- 
2.6.1
