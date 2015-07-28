From: Lars Persson <lars.persson-VrBV9hrLPhE@public.gmane.org>
Subject: [PATCH net-next 4/4] dwc_eth_qos: Add maintainer info
Date: Tue, 28 Jul 2015 12:01:50 +0200
Message-ID: <1438077710-19175-5-git-send-email-larper@axis.com>
References: <1438077710-19175-1-git-send-email-larper@axis.com>
Cc: andire-VrBV9hrLPhE@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org,
	galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, Lars Persson <larper-VrBV9hrLPhE@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1438077710-19175-1-git-send-email-larper-VrBV9hrLPhE@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add maintainer information for the Synopsys DWC Ethernet QOS driver.

Signed-off-by: Lars Persson <larper-VrBV9hrLPhE@public.gmane.org>
---
 MAINTAINERS | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index a226416..0c78766 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8903,6 +8903,13 @@ F:	include/linux/dma/dw.h
 F:	include/linux/platform_data/dma-dw.h
 F:	drivers/dma/dw/
 
+SYNOPSYS DESIGNWARE ETHERNET QOS 4.10a driver
+M: Lars Persson <lars.persson-VrBV9hrLPhE@public.gmane.org>
+L: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
+S: Supported
+F: Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
+F: drivers/net/ethernet/synopsys/dwc_eth_qos.c
+
 SYNOPSYS DESIGNWARE MMC/SD/SDIO DRIVER
 M:	Seungwon Jeon <tgih.jun-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
 M:	Jaehoon Chung <jh80.chung-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
