From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Subject: [PATCH] trivial: remove duplicated "from" in CAN USB EMS Kconfig help
Date: Mon,  1 Feb 2010 15:58:59 -0200
Message-ID: <1265047140-7444-1-git-send-email-cascardo@holoscopio.com>
Cc: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: trivial@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
---
 drivers/net/can/usb/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/usb/Kconfig b/drivers/net/can/usb/Kconfig
index bbc78e0..97ff6fe 100644
--- a/drivers/net/can/usb/Kconfig
+++ b/drivers/net/can/usb/Kconfig
@@ -5,6 +5,6 @@ config CAN_EMS_USB
 	tristate "EMS CPC-USB/ARM7 CAN/USB interface"
 	---help---
 	  This driver is for the one channel CPC-USB/ARM7 CAN/USB interface
-	  from from EMS Dr. Thomas Wuensche (http://www.ems-wuensche.de).
+	  from EMS Dr. Thomas Wuensche (http://www.ems-wuensche.de).
 
 endmenu
-- 
1.6.6.1
