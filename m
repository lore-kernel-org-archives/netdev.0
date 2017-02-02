From: =?UTF-8?q?Amadeusz=20S=C5=82awi=C5=84ski?=
        <amadeusz.slawinski@tieto.com>
Subject: [PATCH 3/3] ath10k: fix comment
Date: Thu,  2 Feb 2017 11:19:33 +0100
Message-ID: <1486030773-30600-3-git-send-email-amadeusz.slawinski@tieto.com>
References: <1486030773-30600-1-git-send-email-amadeusz.slawinski@tieto.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        =?UTF-8?q?Amadeusz=20S=C5=82awi=C5=84ski?=
        <amadeusz.slawinski@tieto.com>
To: ath10k@lists.infradead.org, Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486030773-30600-1-git-send-email-amadeusz.slawinski@tieto.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I wanted to take a look and it's apparently in other header

Signed-off-by: Amadeusz Sławiński <amadeusz.slawinski@tieto.com>
---
 drivers/net/wireless/ath/ath10k/wmi.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath10k/wmi.h b/drivers/net/wireless/ath/ath10k/wmi.h
index 5d3dff9..bf8dcbe 100644
--- a/drivers/net/wireless/ath/ath10k/wmi.h
+++ b/drivers/net/wireless/ath/ath10k/wmi.h
@@ -75,7 +75,7 @@ struct wmi_cmd_hdr {
 
 /*
  * There is no signed version of __le32, so for a temporary solution come
- * up with our own version. The idea is from fs/ntfs/types.h.
+ * up with our own version. The idea is from fs/ntfs/endian.h.
  *
  * Use a_ prefix so that it doesn't conflict if we get proper support to
  * linux/types.h.
-- 
1.9.1
