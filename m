From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v5 11/11] MAINTAINERS: xgene: Add driver and documentation path
Date: Thu,  7 Jul 2016 16:02:59 -0700
Message-ID: <1467932579-14320-12-git-send-email-isubramanian@apm.com>
References: <1467932579-14320-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	matthias.bgg@gmail.com, andrew@lunn.ch, linux@armlinux.org.uk,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35747 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753103AbcGGXDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 19:03:06 -0400
Received: by mail-pa0-f54.google.com with SMTP id dx3so9774519pab.2
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 16:03:05 -0700 (PDT)
In-Reply-To: <1467932579-14320-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added path to the MDIO driver and Documentation file.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 MAINTAINERS | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 6374be2..a2ce997 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -839,7 +839,9 @@ M:	Iyappan Subramanian <isubramanian@apm.com>
 M:	Keyur Chudgar <kchudgar@apm.com>
 S:	Supported
 F:	drivers/net/ethernet/apm/xgene/
+F:	drivers/net/phy/mdio-xgene.c
 F:	Documentation/devicetree/bindings/net/apm-xgene-enet.txt
+F:	Documentation/devicetree/bindings/net/apm-xgene-mdio.txt
 
 APTINA CAMERA SENSOR PLL
 M:	Laurent Pinchart <Laurent.pinchart@ideasonboard.com>
-- 
1.9.1
