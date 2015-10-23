From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net 4/4] MAINTAINERS: Add entry for gianfar ethernet driver
Date: Fri, 23 Oct 2015 11:42:01 +0300
Message-ID: <1445589721-26206-5-git-send-email-claudiu.manoil@freescale.com>
References: <1445589721-26206-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0105.outbound.protection.outlook.com ([65.55.169.105]:36304
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751080AbbJWJPu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 05:15:50 -0400
In-Reply-To: <1445589721-26206-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 MAINTAINERS | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index fb7d2e4..9b43ef2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4427,6 +4427,14 @@ L:	linuxppc-dev@lists.ozlabs.org
 S:	Maintained
 F:	drivers/net/ethernet/freescale/ucc_geth*
 
+FREESCALE eTSEC ETHERNET DRIVER (GIANFAR)
+M:	Claudiu Manoil <claudiu.manoil@freescale.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/ethernet/freescale/gianfar*
+X:	drivers/net/ethernet/freescale/gianfar_ptp.c
+F:	Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
+
 FREESCALE QUICC ENGINE UCC UART DRIVER
 M:	Timur Tabi <timur@tabi.org>
 L:	linuxppc-dev@lists.ozlabs.org
-- 
1.7.11.7
