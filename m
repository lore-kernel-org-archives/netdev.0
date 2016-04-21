From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2] MAINTAINERS: net: add entry for TI Ethernet Switch drivers
Date: Thu, 21 Apr 2016 13:13:56 +0300
Message-ID: <1461233636-18667-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-omap@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	Tony Lindgren <tony@atomide.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Richard Cochran <richardcochran@gmail.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add record for TI Ethernet Switch Driver CPSW/CPDMA/MDIO HW
(am33/am43/am57/dr7/davinci) to ensure that related patches
will go through dedicated linux-omap list.

Also add Mugunthan as maintainer and myself as the reviewer.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Tony Lindgren <tony@atomide.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Cc: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
Changes in v2:
 - added netdev@vger.kernel.org list

 MAINTAINERS | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 1d5b4be..8491336 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -11071,6 +11071,15 @@ S:	Maintained
 F:	drivers/clk/ti/
 F:	include/linux/clk/ti.h
 
+TI ETHERNET SWITCH DRIVER (CPSW)
+M:	Mugunthan V N <mugunthanvnm@ti.com>
+R:	Grygorii Strashko <grygorii.strashko@ti.com>
+L:	linux-omap@vger.kernel.org
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/ethernet/ti/cpsw*
+F:	drivers/net/ethernet/ti/davinci*
+
 TI FLASH MEDIA INTERFACE DRIVER
 M:	Alex Dubov <oakad@yahoo.com>
 S:	Maintained
-- 
2.8.1
