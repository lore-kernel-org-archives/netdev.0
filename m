From: Tomoya MORINAGA <tomoya.rohm@gmail.com>
Subject: [PATCH 2/3] ethernet/pch_gbe: add Intel EG20T PCH
Date: Fri, 27 Jan 2012 14:45:55 +0900
Message-ID: <1327643159-1302-2-git-send-email-tomoya.rohm@gmail.com>
References: <1327643159-1302-1-git-send-email-tomoya.rohm@gmail.com>
Cc: qi.wang@intel.com, yong.y.wang@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, Tomoya MORINAGA <tomoya.rohm@gmail.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327643159-1302-1-git-send-email-tomoya.rohm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Previous patch deleted description "Intel EG20T PCH".
So, I add this again.

Signed-off-by: Tomoya MORINAGA <tomoya.rohm@gmail.com>
---
 drivers/net/ethernet/lapis-semi/pch_gbe/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/lapis-semi/pch_gbe/Kconfig b/drivers/net/ethernet/lapis-semi/pch_gbe/Kconfig
index 7dd8dc7..af3768c 100644
--- a/drivers/net/ethernet/lapis-semi/pch_gbe/Kconfig
+++ b/drivers/net/ethernet/lapis-semi/pch_gbe/Kconfig
@@ -3,7 +3,7 @@
 #
 
 config PCH_GBE
-	tristate "LAPIS SEMICONDUCTOR IOH(ML7223/ML7831) GbE"
+	tristate "Intel EG20T PCH/LAPIS Semicon IOH(ML7223/ML7831) GbE"
 	depends on PCI
 	select NET_CORE
 	select MII
-- 
1.7.7.4
