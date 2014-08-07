From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v10 1/4] MAINTAINERS: Add entry for APM X-Gene SoC ethernet driver
Date: Thu,  7 Aug 2014 15:14:25 -0700
Message-ID: <1407449668-13520-2-git-send-email-isubramanian@apm.com>
References: <1407449668-13520-1-git-send-email-isubramanian@apm.com>
Cc: dnelson@redhat.com, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	jcm@redhat.com, patches@apm.com,
	Iyappan Subramanian <isubramanian@apm.com>,
	Ravi Patel <rapatel@apm.com>, Keyur Chudgar <kchudgar@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407449668-13520-1-git-send-email-isubramanian@apm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a MAINTAINERS entry for APM X-Gene SoC
ethernet driver.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Ravi Patel <rapatel@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 MAINTAINERS | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 05e5450..e8ac352 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -719,6 +719,14 @@ S:	Maintained
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
