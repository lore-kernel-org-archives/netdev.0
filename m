From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH v3 net-next 2/5] net: dsa: lan9303: define LAN9303_NUM_PORTS 3
Date: Thu,  3 Aug 2017 11:45:04 +0200
Message-ID: <20170803094507.3439-3-privat@egil-hjelmeland.no>
References: <20170803094507.3439-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170803094507.3439-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Will be used instead of '3' in upcomming patches.

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 drivers/net/dsa/lan9303-core.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index fa19e320c5a8..126e8b84bdf0 100644
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
