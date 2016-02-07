From: "Andrew F. Davis" <afd@ti.com>
Subject: [PATCH v2 5/5] net: phy: dp83848: Add comments for register definitions
Date: Sun, 7 Feb 2016 11:47:21 -0600
Message-ID: <1454867241-20928-6-git-send-email-afd@ti.com>
References: <1454867241-20928-1-git-send-email-afd@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"Andrew F. Davis" <afd@ti.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454867241-20928-1-git-send-email-afd@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Andrew F. Davis <afd@ti.com>
---
 drivers/net/phy/dp83848.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/dp83848.c b/drivers/net/phy/dp83848.c
index f897989..556904f 100644
--- a/drivers/net/phy/dp83848.c
+++ b/drivers/net/phy/dp83848.c
@@ -21,8 +21,8 @@
 #define TLK10X_PHY_ID			0x2000a210
 
 /* Registers */
-#define DP83848_MICR			0x11
-#define DP83848_MISR			0x12
+#define DP83848_MICR			0x11 /* MII Interrupt Control Register */
+#define DP83848_MISR			0x12 /* MII Interrupt Status Register */
 
 /* MICR Register Fields */
 #define DP83848_MICR_INT_OE		BIT(0) /* Interrupt Output Enable */
-- 
2.7.0
