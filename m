From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH] drivers/net/wireless/Kconfig: correct minor typo
Date: Mon, 23 Apr 2007 15:53:13 -0400
Message-ID: <20070423195313.GG5883@tuxdriver.com>
References: <20070423183334.GC5883@tuxdriver.com> <20070423183443.GD5883@tuxdriver.com> <20070423213519.2692d0fd@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070423213519.2692d0fd@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Correct minor typo in drivers/net/wireless/Kconfig identified by
Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>.

Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
---
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 880c628..4426841 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -11,7 +11,7 @@ config WLAN_PRE80211
 	  Say Y if you have any pre-802.11 wireless LAN hardware.
 
 	  This option does not affect the kernel build, it only
-	  let's you choose drivers.
+	  lets you choose drivers.
 
 config STRIP
 	tristate "STRIP (Metricom starmode radio IP)"
@@ -112,7 +112,7 @@ config WLAN_80211
 	  Say Y if you have any 802.11 wireless LAN hardware.
 
 	  This option does not affect the kernel build, it only
-	  let's you choose drivers.
+	  lets you choose drivers.
 
 config PCMCIA_RAYCS
 	tristate "Aviator/Raytheon 2.4MHz wireless support"

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
