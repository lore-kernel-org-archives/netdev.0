From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH] MAINTAINERS: add maintainer entry for FREESCALE FEC ethernet driver
Date: Wed, 2 Mar 2016 17:24:53 +0800
Message-ID: <1456910693-25787-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <fugang.duan@nxp.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0135.outbound.protection.outlook.com ([65.55.169.135]:63622
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751085AbcCBK7J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 05:59:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a maintainer entry for FREESCALE FEC ethernet driver and add myself
as a maintainer.

Signed-off-by: Fugang Duan <fugang.duan@nxp.com>
---
 MAINTAINERS | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 0499f9e..4d4b18f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4552,6 +4552,15 @@ S:	Maintained
 F:	drivers/net/ethernet/freescale/fs_enet/
 F:	include/linux/fs_enet_pd.h
 
+FREESCALE IMX / MXC FEC DRIVER
+M:	Fugang Duan <fugang.duan@nxp.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/ethernet/freescale/fec_main.c
+F:	drivers/net/ethernet/freescale/fec_ptp.c
+F:	drivers/net/ethernet/freescale/fec.h
+F:	Documentation/devicetree/bindings/net/fsl-fec.txt
+
 FREESCALE QUICC ENGINE LIBRARY
 L:	linuxppc-dev@lists.ozlabs.org
 S:	Orphan
-- 
1.9.1
