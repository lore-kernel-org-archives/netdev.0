From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 6/6] MAINTAINERS: Add entry for APM X-Gene SoC Ethernet (v2) driver
Date: Tue, 31 Jan 2017 11:03:21 -0800
Message-ID: <1485889401-13909-7-git-send-email-isubramanian@apm.com>
References: <1485889401-13909-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        kchudgar@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34565 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751825AbdAaTFR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 14:05:17 -0500
Received: by mail-pf0-f169.google.com with SMTP id e4so109482280pfg.1
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 11:03:29 -0800 (PST)
In-Reply-To: <1485889401-13909-1-git-send-email-isubramanian@apm.com>
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
index cc106f7..35f4eeb 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -896,6 +896,12 @@ F:	drivers/net/phy/mdio-xgene.c
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
