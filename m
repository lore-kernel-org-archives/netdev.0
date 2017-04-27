From: ammly <ammlyf@gmail.com>
Subject: [PATCH] net: ath: tx99: fixed a spelling issue
Date: Thu, 27 Apr 2017 19:31:37 +0300
Message-ID: <1493310697-18610-1-git-send-email-ammly@gmail.com>
Cc: kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ammly Fredrick <ammlyf@gmail.com>
To: ath9k-devel@qca.qualcomm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34441 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932722AbdD0Qbu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 12:31:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed a spelling issue.

Signed-off-by: Ammly Fredrick <ammlyf@gmail.com>
---
 drivers/net/wireless/ath/ath9k/tx99.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/tx99.c b/drivers/net/wireless/ath/ath9k/tx99.c
index 16aca9e28b77..a866cbda0799 100644
--- a/drivers/net/wireless/ath/ath9k/tx99.c
+++ b/drivers/net/wireless/ath/ath9k/tx99.c
@@ -153,7 +153,7 @@ static int ath9k_tx99_init(struct ath_softc *sc)
 		sc->tx99_power,
 		sc->tx99_power / 2);
 
-	/* We leave the harware awake as it will be chugging on */
+	/* We leave the hardware awake as it will be chugging on */
 
 	return 0;
 }
-- 
2.11.0
