From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v7 1/4] MAINTAINERS: Add entry for APM X-Gene SoC ethernet driver
Date: Wed, 18 Jun 2014 18:17:11 -0700
Message-ID: <1403140634-27104-2-git-send-email-isubramanian@apm.com>
References: <1403140634-27104-1-git-send-email-isubramanian@apm.com>
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, jcm@redhat.com,
	patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>,
	Ravi Patel <rapatel@apm.com>, Keyur Chudgar <kchudgar@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og121.obsmtp.com ([64.18.0.139]:39475 "HELO
	exprod5og121.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756870AbaFSBRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 21:17:14 -0400
Received: by mail-pd0-f174.google.com with SMTP id y10so1243547pdj.5
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2014 18:17:13 -0700 (PDT)
In-Reply-To: <1403140634-27104-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a MAINTAINERS entry for APM X-Gene SoC
ethernet driver.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Ravi Patel <rapatel@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 MAINTAINERS | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 134483f..d65a3be 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -700,6 +700,14 @@ S:	Maintained
 F:	drivers/net/appletalk/
 F:	net/appletalk/
 
+APPLIED MICRO (APM) X-GENE SOC ETHERNET DRIVER
+M:	Iyappan Subramanian <isubramanian@apm.com>
+M:	Keyur Chudgar <kchudgar@apm.com>
+M:	Ravi Patel <rapatel@apm.com>
+S:	Supported
+F:	drivers/net/ethernet/apm/xgene/
+F:	Documentation/devicetree/bindings/net/apm-xgene-enet.txt
+
 APTINA CAMERA SENSOR PLL
 M:	Laurent Pinchart <Laurent.pinchart@ideasonboard.com>
 L:	linux-media@vger.kernel.org
-- 
1.9.1
