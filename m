From: John Crispin <blogic@openwrt.org>
Subject: [PATCH 12/12] net-next: mediatek: add an entry to MAINTAINERS
Date: Sun,  3 Jan 2016 16:26:15 +0100
Message-ID: <1451834775-15789-12-git-send-email-blogic@openwrt.org>
References: <1451834775-15789-1-git-send-email-blogic@openwrt.org>
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	linux-mediatek@lists.infradead.org,
	John Crispin <blogic@openwrt.org>,
	Felix Fietkau <nbd@nbd.name>, Michael Lee <igvtee@gmail.com>,
	=?UTF-8?q?Steven=20Liu=20=28=E5=8A=89=E4=BA=BA=E8=B1=AA=29?=
	<steven.liu@mediatek.com>,
	=?UTF-8?q?Fred=20Chang=20=28=E5=BC=B5=E5=98=89=E5=AE=8F=29?=
	<Fred.Chang@mediatek.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:55411 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751569AbcACP1j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jan 2016 10:27:39 -0500
In-Reply-To: <1451834775-15789-1-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: John Crispin <blogic@openwrt.org>
---
 MAINTAINERS |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index ea17512..767f108 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6897,6 +6897,13 @@ F:	include/uapi/linux/meye.h
 F:	include/uapi/linux/ivtv*
 F:	include/uapi/linux/uvcvideo.h
 
+MEDIATEK ETHERNET DRIVER
+M:	John Crispin <blogic@openwrt.org>
+M:	Felix Fietkau <nbd@openwrt.org>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/ethernet/mediatek/
+
 MEDIATEK MT7601U WIRELESS LAN DRIVER
 M:	Jakub Kicinski <kubakici@wp.pl>
 L:	linux-wireless@vger.kernel.org
-- 
1.7.10.4
