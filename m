From: Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/1] iwmc3200: add more SDIO device ids
Date: Tue, 25 Aug 2009 00:34:19 +0300
Message-ID: <1251149659-32212-1-git-send-email-tomas.winkler@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

add WiFi BGN SKU and WiMAX 2.4GHz SKU device ids

Cc:inaky.perez-gonzalez-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Cc:cindy.h.kao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Cc:yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Signed-off-by: Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 include/linux/mmc/sdio_ids.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/mmc/sdio_ids.h b/include/linux/mmc/sdio_ids.h
index 2dbfb5a..addd456 100644
--- a/include/linux/mmc/sdio_ids.h
+++ b/include/linux/mmc/sdio_ids.h
@@ -28,6 +28,8 @@
 #define SDIO_DEVICE_ID_INTEL_IWMC3200TOP	0x1404
 #define SDIO_DEVICE_ID_INTEL_IWMC3200GPS	0x1405
 #define SDIO_DEVICE_ID_INTEL_IWMC3200BT		0x1406
+#define SDIO_DEVICE_ID_INTEL_IWMC3200WIMAX_24	0x1407
+#define SDIO_DEVICE_ID_INTEL_IWMC3200WIFI_BGN	0x1408
 
 #define SDIO_VENDOR_ID_MARVELL			0x02df
 #define SDIO_DEVICE_ID_MARVELL_LIBERTAS		0x9103
-- 
1.6.0.6

---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
