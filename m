From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 6/7] ath6kl: fix typo
Date: Tue, 17 May 2016 16:38:45 +0200
Message-ID: <1463495926-13728-7-git-send-email-Julia.Lawall@lip6.fr>
References: <1463495926-13728-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463495926-13728-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

firmare -> firmware

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/wireless/ath/ath6kl/core.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath6kl/core.h b/drivers/net/wireless/ath/ath6kl/core.h
index 713a571..ebc40f6 100644
--- a/drivers/net/wireless/ath/ath6kl/core.h
+++ b/drivers/net/wireless/ath/ath6kl/core.h
@@ -148,7 +148,7 @@ enum ath6kl_fw_capability {
 	/* ratetable is the 2 stream version (max MCS15) */
 	ATH6KL_FW_CAPABILITY_RATETABLE_MCS15,
 
-	/* firmare doesn't support IP checksumming */
+	/* firmware doesn't support IP checksumming */
 	ATH6KL_FW_CAPABILITY_NO_IP_CHECKSUM,
 
 	/* this needs to be last */
