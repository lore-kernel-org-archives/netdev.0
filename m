From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [net-next 13/13] MAINTAINERS: net: add entry for Freescale QorIQ DPAA FMan driver
Date: Tue, 4 Oct 2016 10:32:59 +0300
Message-ID: <1475566379-5078-14-git-send-email-madalin.bucur@nxp.com>
References: <1475566379-5078-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linuxppc-dev@lists.ozlabs.org>,
        <linux-kernel@vger.kernel.org>, <linuxdev.baldrick@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0056.outbound.protection.outlook.com ([104.47.32.56]:64648
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753537AbcJDHtQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 03:49:16 -0400
In-Reply-To: <1475566379-5078-1-git-send-email-madalin.bucur@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add record for Freescale QORIQ DPAA FMan driver adding myself as
maintainer.

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 MAINTAINERS | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 669909e..3460152 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4980,6 +4980,13 @@ F:	drivers/net/ethernet/freescale/fec_ptp.c
 F:	drivers/net/ethernet/freescale/fec.h
 F:	Documentation/devicetree/bindings/net/fsl-fec.txt
 
+FREESCALE QORIQ DPAA FMAN DRIVER
+M:	Madalin Bucur <madalin.bucur@nxp.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/ethernet/freescale/fman
+F:	Documentation/devicetree/bindings/powerpc/fsl/fman.txt
+
 FREESCALE QUICC ENGINE LIBRARY
 L:	linuxppc-dev@lists.ozlabs.org
 S:	Orphan
-- 
2.1.0
