From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v1 1/5] MAINTAINERS: Update APM X-Gene section
Date: Tue, 23 Sep 2014 20:51:24 -0700
Message-ID: <1411530688-2939-2-git-send-email-isubramanian@apm.com>
References: <1411530688-2939-1-git-send-email-isubramanian@apm.com>
Cc: kchudgar@apm.com, patches@apm.com,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og111.obsmtp.com ([64.18.0.22]:53223 "HELO
	exprod5og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750711AbaIXDvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 23:51:42 -0400
Received: by mail-pd0-f175.google.com with SMTP id v10so6629366pde.6
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 20:51:41 -0700 (PDT)
In-Reply-To: <1411530688-2939-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update APM X-Gene ethernet driver maintainers list.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 MAINTAINERS | 1 -
 1 file changed, 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index b4e23ac..74d202a 100644
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
