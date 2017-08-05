From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH v4 net-next 2/5] net: dsa: lan9303: define LAN9303_NUM_PORTS 3
Date: Sat,  5 Aug 2017 13:05:47 +0200
Message-ID: <20170805110550.26337-3-privat@egil-hjelmeland.no>
References: <20170805110550.26337-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170805110550.26337-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Will be used instead of '3' in upcomming patches.

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/lan9303-core.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index 77f3cee3af0d..49e3a0cb1b5b 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -20,6 +20,8 @@
 
 #include "lan9303.h"
 
+#define LAN9303_NUM_PORTS 3
+
 /* 13.2 System Control and Status Registers
  * Multiply register number by 4 to get address offset.
  */
-- 
2.11.0
