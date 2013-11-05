From: Joe Perches <joe@perches.com>
Subject: [PATCH] jme: Remove unused #define PFX
Date: Tue, 05 Nov 2013 09:29:55 -0800
Message-ID: <1383672595.4387.23.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	LKML <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's unused, remove it.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/jme.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/jme.h b/drivers/net/ethernet/jme.h
index 3efc897..58cd67c 100644
--- a/drivers/net/ethernet/jme.h
+++ b/drivers/net/ethernet/jme.h
@@ -28,7 +28,6 @@
 
 #define DRV_NAME	"jme"
 #define DRV_VERSION	"1.0.8"
-#define PFX		DRV_NAME ": "
 
 #define PCI_DEVICE_ID_JMICRON_JMC250	0x0250
 #define PCI_DEVICE_ID_JMICRON_JMC260	0x0260
