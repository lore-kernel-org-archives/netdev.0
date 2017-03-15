From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 7/7] MAINTAINERS: Update X-Gene SoC ethernet maintainer
Date: Wed, 15 Mar 2017 13:27:21 -0700
Message-ID: <1489609641-31557-8-git-send-email-isubramanian@apm.com>
References: <1489609641-31557-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        kchudgar@apm.com, qnguyen@apm.com,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35922 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751495AbdCOU0O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 16:26:14 -0400
Received: by mail-pg0-f50.google.com with SMTP id g2so14060839pge.3
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 13:26:13 -0700 (PDT)
In-Reply-To: <1489609641-31557-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
Signed-off-by: Quan Nguyen <qnguyen@apm.com>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index cefda30..632e762 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -896,6 +896,7 @@ F:	arch/arm64/boot/dts/apm/
 APPLIED MICRO (APM) X-GENE SOC ETHERNET DRIVER
 M:	Iyappan Subramanian <isubramanian@apm.com>
 M:	Keyur Chudgar <kchudgar@apm.com>
+M:	Quan Nguyen <qnguyen@apm.com>
 S:	Supported
 F:	drivers/net/ethernet/apm/xgene/
 F:	drivers/net/phy/mdio-xgene.c
-- 
1.9.1
