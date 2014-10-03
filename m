From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 1/6] MAINTAINERS: Update APM X-Gene section
Date: Thu,  2 Oct 2014 17:02:43 -0700
Message-ID: <1412294568-26747-2-git-send-email-isubramanian@apm.com>
References: <1412294568-26747-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	kchudgar@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og122.obsmtp.com ([64.18.0.192]:54973 "HELO
	exprod5og122.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751882AbaJCADR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 20:03:17 -0400
Received: by mail-pa0-f47.google.com with SMTP id rd3so293878pab.34
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 17:03:16 -0700 (PDT)
In-Reply-To: <1412294568-26747-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updated APM X-Gene ethernet driver maintainers list.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 MAINTAINERS | 1 -
 1 file changed, 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index c2e7a06..6a3d689 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -722,7 +722,6 @@ F:	net/appletalk/
 APPLIED MICRO (APM) X-GENE SOC ETHERNET DRIVER
 M:	Iyappan Subramanian <isubramanian@apm.com>
 M:	Keyur Chudgar <kchudgar@apm.com>
-M:	Ravi Patel <rapatel@apm.com>
 S:	Supported
 F:	drivers/net/ethernet/apm/xgene/
 F:	Documentation/devicetree/bindings/net/apm-xgene-enet.txt
-- 
1.9.1
