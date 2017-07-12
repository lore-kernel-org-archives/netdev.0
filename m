From: <sean.wang@mediatek.com>
Subject: [PATCH net-next 4/4] MAINTAINERS: add Sean/Nelson as MediaTek ethernet maintainers
Date: Wed, 12 Jul 2017 11:37:45 +0800
Message-ID: <8577c940141134473dc72613d8d24ce19476c28a.1499829241.git.sean.wang@mediatek.com>
References: <cover.1499829241.git.sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>,
        "Sean Wang" <sean.wang@mediatek.com>,
        Nelson Chang <nelson.chang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1499829241.git.sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang@mediatek.com>

Sean and Nelson work for MediaTek on maintaining the MediaTek ethernet
driver for the existing SoCs and adding support for the following SoCs.
In the past, Sean has been active at making most of the qualifications
, stress test and submitting a lot of patches for the driver while
Nelson was looking into the aspects more on hardware additions and details
such as introducing PDMA with Hardware LRO to the driver.

Cc: John Crispin <john@phrozen.org>
Signed-off-by: Sean Wang <sean.wang@mediatek.com>
Signed-off-by: Nelson Chang <nelson.chang@mediatek.com>
---
 MAINTAINERS | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 4f4057c..3b2dd4b 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8385,6 +8385,8 @@ F:	include/uapi/linux/uvcvideo.h
 MEDIATEK ETHERNET DRIVER
 M:	Felix Fietkau <nbd@openwrt.org>
 M:	John Crispin <blogic@openwrt.org>
+M:	Sean Wang <sean.wang@mediatek.com>
+M:	Nelson Chang <nelson.chang@mediatek.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
 F:	drivers/net/ethernet/mediatek/
-- 
2.7.4
