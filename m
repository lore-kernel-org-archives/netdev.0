From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 12/12] sfc: Update version, copyright dates, authors
Date: Mon, 30 Nov 2009 01:16:19 +0000
Message-ID: <1259543779.3709.98.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:46842 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178AbZK3BQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:16:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver has been mostly rewritten since Michael Brown's initial
work, so swap the order of the authors.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/bitfield.h      |    2 +-
 drivers/net/sfc/efx.c           |    6 +++---
 drivers/net/sfc/efx.h           |    2 +-
 drivers/net/sfc/enum.h          |    2 +-
 drivers/net/sfc/ethtool.c       |    2 +-
 drivers/net/sfc/falcon.c        |    2 +-
 drivers/net/sfc/falcon_boards.c |    2 +-
 drivers/net/sfc/falcon_gmac.c   |    2 +-
 drivers/net/sfc/falcon_xmac.c   |    2 +-
 drivers/net/sfc/mac.h           |    2 +-
 drivers/net/sfc/mdio_10g.c      |    2 +-
 drivers/net/sfc/mdio_10g.h      |    2 +-
 drivers/net/sfc/mtd.c           |    2 +-
 drivers/net/sfc/net_driver.h    |    4 ++--
 drivers/net/sfc/nic.c           |    2 +-
 drivers/net/sfc/nic.h           |    2 +-
 drivers/net/sfc/phy.h           |    2 +-
 drivers/net/sfc/qt202x_phy.c    |    2 +-
 drivers/net/sfc/rx.c            |    2 +-
 drivers/net/sfc/selftest.c      |    2 +-
 drivers/net/sfc/tenxpress.c     |    2 +-
 drivers/net/sfc/tx.c            |    2 +-
 drivers/net/sfc/workarounds.h   |    2 +-
 23 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/drivers/net/sfc/bitfield.h b/drivers/net/sfc/bitfield.h
index bb5de4f..098ac2a 100644
--- a/drivers/net/sfc/bitfield.h
+++ b/drivers/net/sfc/bitfield.h
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2008 Solarflare Communications Inc.
+ * Copyright 2006-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 3c0d6be..f983e3b 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2005-2008 Solarflare Communications Inc.
+ * Copyright 2005-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
@@ -2453,8 +2453,8 @@ static void __exit efx_exit_module(void)
 module_init(efx_init_module);
 module_exit(efx_exit_module);
 
-MODULE_AUTHOR("Michael Brown <mbrown@fensystems.co.uk> and "
-	      "Solarflare Communications");
+MODULE_AUTHOR("Solarflare Communications and "
+	      "Michael Brown <mbrown@fensystems.co.uk>");
 MODULE_DESCRIPTION("Solarflare Communications network driver");
 MODULE_LICENSE("GPL");
 MODULE_DEVICE_TABLE(pci, efx_pci_table);
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index b4470da..a615ac0 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2008 Solarflare Communications Inc.
+ * Copyright 2006-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/enum.h b/drivers/net/sfc/enum.h
index b1f7a40..384cfe3 100644
--- a/drivers/net/sfc/enum.h
+++ b/drivers/net/sfc/enum.h
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2007-2008 Solarflare Communications Inc.
+ * Copyright 2007-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index f698121..6c0bbed 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2008 Solarflare Communications Inc.
+ * Copyright 2006-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 48d28d8..17afcd2 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2008 Solarflare Communications Inc.
+ * Copyright 2006-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index fa4d4c7..bf0b96a 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2007-2008 Solarflare Communications Inc.
+ * Copyright 2007-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/falcon_gmac.c b/drivers/net/sfc/falcon_gmac.c
index aa9b689..7dadfcb 100644
--- a/drivers/net/sfc/falcon_gmac.c
+++ b/drivers/net/sfc/falcon_gmac.c
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2008 Solarflare Communications Inc.
+ * Copyright 2006-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index cd63f24..3da933f 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2008 Solarflare Communications Inc.
+ * Copyright 2006-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/mac.h b/drivers/net/sfc/mac.h
index c733863..f1aa5f3 100644
--- a/drivers/net/sfc/mac.h
+++ b/drivers/net/sfc/mac.h
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2008 Solarflare Communications Inc.
+ * Copyright 2006-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 19496da..1574e52 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2006-2008 Solarflare Communications Inc.
+ * Copyright 2006-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index dbc8e7d..f6ac950 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2006-2008 Solarflare Communications Inc.
+ * Copyright 2006-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/mtd.c b/drivers/net/sfc/mtd.c
index ef561f8..3a46452 100644
--- a/drivers/net/sfc/mtd.c
+++ b/drivers/net/sfc/mtd.c
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2008 Solarflare Communications Inc.
+ * Copyright 2006-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index ec13203..34c381f 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2005-2008 Solarflare Communications Inc.
+ * Copyright 2005-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
@@ -38,7 +38,7 @@
 #ifndef EFX_DRIVER_NAME
 #define EFX_DRIVER_NAME	"sfc"
 #endif
-#define EFX_DRIVER_VERSION	"2.3"
+#define EFX_DRIVER_VERSION	"3.0"
 
 #ifdef EFX_ENABLE_DEBUG
 #define EFX_BUG_ON_PARANOID(x) BUG_ON(x)
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 5ac4b1a..a577be2 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2008 Solarflare Communications Inc.
+ * Copyright 2006-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/nic.h b/drivers/net/sfc/nic.h
index 57c510d..9351c03 100644
--- a/drivers/net/sfc/nic.h
+++ b/drivers/net/sfc/nic.h
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2008 Solarflare Communications Inc.
+ * Copyright 2006-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/phy.h b/drivers/net/sfc/phy.h
index 64dff2d..5bc2613 100644
--- a/drivers/net/sfc/phy.h
+++ b/drivers/net/sfc/phy.h
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2007-2008 Solarflare Communications Inc.
+ * Copyright 2007-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/qt202x_phy.c b/drivers/net/sfc/qt202x_phy.c
index 957e534..3800fc7 100644
--- a/drivers/net/sfc/qt202x_phy.c
+++ b/drivers/net/sfc/qt202x_phy.c
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2006-2008 Solarflare Communications Inc.
+ * Copyright 2006-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 03eace3..a97c923 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2005-2008 Solarflare Communications Inc.
+ * Copyright 2005-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 1635f57..14949bb 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2008 Solarflare Communications Inc.
+ * Copyright 2006-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index ff97133..ca11572 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2007-2008 Solarflare Communications Inc.
+ * Copyright 2007-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 582fc75..e669f94 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2005-2008 Solarflare Communications Inc.
+ * Copyright 2005-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index ecee8f5..acd9c73 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2006-2008 Solarflare Communications Inc.
+ * Copyright 2006-2009 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
-- 
1.6.5.3



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

