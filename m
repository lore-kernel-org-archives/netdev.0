From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH v7 3/3] MAINTAINER: net: Add TI NETCP Ethernet driver entry
Date: Tue, 2 Dec 2014 16:41:43 -0500
Message-ID: <1417556503-22290-4-git-send-email-m-karicheri2@ti.com>
References: <1417556503-22290-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Murali Karicheri <m-karicheri2@ti.com>, Sandeep Nair <sandeep_n@ti.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
 <linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
 <devicetree@vger.kernel.org>, <robh+dt@kernel.org>,
 <grant.likely@linaro.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1417556503-22290-1-git-send-email-m-karicheri2@ti.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

CC: David Miller <davem@davemloft.net>
Signed-off-by: Sandeep Nair <sandeep_n@ti.com>
Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 MAINTAINERS |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index ea4d005..bc876f2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9337,6 +9337,14 @@ F:	drivers/power/lp8788-charger.c
 F:	drivers/regulator/lp8788-*.c
 F:	include/linux/mfd/lp8788*.h
 
+TI NETCP ETHERNET DRIVER
+M:	Sandeep Nair <sandeepn02@gmail.com>
+M:	Murali Karicheri <m-karicheri2@ti.com>
+M:	Santosh Shilimkar <santosh.shilimkar@kernel.org>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/ethernet/ti/netcp*
+
 TI TWL4030 SERIES SOC CODEC DRIVER
 M:	Peter Ujfalusi <peter.ujfalusi@ti.com>
 L:	alsa-devel@alsa-project.org (moderated for non-subscribers)
-- 
1.7.9.5
