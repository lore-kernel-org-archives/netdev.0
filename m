From: Tomoya MORINAGA <tomoya.rohm@gmail.com>
Subject: [PATCH 3/3] ethernet: Change author mail address
Date: Fri, 27 Jan 2012 14:45:56 +0900
Message-ID: <1327643159-1302-3-git-send-email-tomoya.rohm@gmail.com>
References: <1327643159-1302-1-git-send-email-tomoya.rohm@gmail.com>
Cc: qi.wang@intel.com, yong.y.wang@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, Tomoya MORINAGA <tomoya.rohm@gmail.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327643159-1302-1-git-send-email-tomoya.rohm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Tomoya MORINAGA <tomoya.rohm@gmail.com>
---
 .../net/ethernet/lapis-semi/pch_gbe/pch_gbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/lapis-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/lapis-semi/pch_gbe/pch_gbe_main.c
index a6297fd..c1a99c7 100644
--- a/drivers/net/ethernet/lapis-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/lapis-semi/pch_gbe/pch_gbe_main.c
@@ -2593,7 +2593,7 @@ module_init(pch_gbe_init_module);
 module_exit(pch_gbe_exit_module);
 
 MODULE_DESCRIPTION("EG20T PCH Gigabit ethernet Driver");
-MODULE_AUTHOR("LAPIS SEMICONDUCTOR, <toshiharu-linux@dsn.lapis-semi.com>");
+MODULE_AUTHOR("LAPIS SEMICONDUCTOR, <tomoya.rohm@gmail.com>");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 MODULE_DEVICE_TABLE(pci, pch_gbe_pcidev_id);
-- 
1.7.7.4
