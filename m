From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v3 net-next 6/6] MAINTAINERS: Add entry for APM X-Gene SoC Ethernet (v2) driver
Date: Fri,  3 Mar 2017 17:09:32 -0800
Message-ID: <1488589773-28055-7-git-send-email-isubramanian@apm.com>
References: <1488589773-28055-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        kchudgar@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org, andrew@lunn.ch,
        f.fainelli@gmail.com, David.Laight@aculab.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:36354 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751951AbdCDBIs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 20:08:48 -0500
Received: by mail-pg0-f49.google.com with SMTP id s67so49131418pgb.3
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 17:08:47 -0800 (PST)
In-Reply-To: <1488589773-28055-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a MAINTAINERS entry for the ethernet driver for
the on-chip ethernet interface which uses a linked list of DMA
descriptor architecture (v2) for APM X-Gene SoCs.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 MAINTAINERS | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 846f97a..ccb9814 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -902,6 +902,12 @@ F:	drivers/net/phy/mdio-xgene.c
 F:	Documentation/devicetree/bindings/net/apm-xgene-enet.txt
 F:	Documentation/devicetree/bindings/net/apm-xgene-mdio.txt
 
+APPLIED MICRO (APM) X-GENE SOC ETHERNET (V2) DRIVER
+M:	Iyappan Subramanian <isubramanian@apm.com>
+M:	Keyur Chudgar <kchudgar@apm.com>
+S:	Supported
+F:	drivers/net/ethernet/apm/xgene-v2/
+
 APPLIED MICRO (APM) X-GENE SOC PMU
 M:	Tai Nguyen <ttnguyen@apm.com>
 S:	Supported
-- 
1.9.1
