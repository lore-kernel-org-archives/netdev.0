From: John Crispin <blogic@openwrt.org>
Subject: [PATCH V3 4/4] net-next: mediatek: add an entry to MAINTAINERS
Date: Thu,  3 Mar 2016 21:02:41 +0100
Message-ID: <1457035361-57669-5-git-send-email-blogic@openwrt.org>
References: <1457035361-57669-1-git-send-email-blogic@openwrt.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org,
	=?UTF-8?q?Steven=20Liu=20=28=E5=8A=89=E4=BA=BA=E8=B1=AA=29?=
	<steven.liu@mediatek.com>,
	=?UTF-8?q?Carlos=20Huang=20=28=E9=BB=83=E5=A3=AB=E5=BD=B0=29?=
	<Carlos.Huang@mediatek.com>, Felix Fietkau <nbd@openwrt.org>,
	Michael Lee <igvtee@gmail.com>,
	John Crispin <blogic@openwrt.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457035361-57669-1-git-send-email-blogic@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add myself and Felix as the Maintainers for the MediaTek ethernet driver.

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: John Crispin <blogic@openwrt.org>
---
 MAINTAINERS |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 9c4d157..b5293f3 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7012,6 +7012,13 @@ F:	include/uapi/linux/meye.h
 F:	include/uapi/linux/ivtv*
 F:	include/uapi/linux/uvcvideo.h
 
+MEDIATEK ETHERNET DRIVER
+M:	Felix Fietkau <nbd@openwrt.org>
+M:	John Crispin <blogic@openwrt.org>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/ethernet/mediatek/
+
 MEDIATEK MT7601U WIRELESS LAN DRIVER
 M:	Jakub Kicinski <kubakici@wp.pl>
 L:	linux-wireless@vger.kernel.org
-- 
1.7.10.4
