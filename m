From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 5/8] sfc: Update copyright dates
Date: Tue, 01 Mar 2011 01:23:05 +0000
Message-ID: <1298942585.3069.184.camel@localhost>
References: <1298942169.3069.179.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12082 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754634Ab1CABXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 20:23:10 -0500
In-Reply-To: <1298942169.3069.179.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c           |    2 +-
 drivers/net/sfc/efx.h           |    2 +-
 drivers/net/sfc/ethtool.c       |    2 +-
 drivers/net/sfc/falcon.c        |    2 +-
 drivers/net/sfc/falcon_boards.c |    2 +-
 drivers/net/sfc/falcon_xmac.c   |    2 +-
 drivers/net/sfc/io.h            |    2 +-
 drivers/net/sfc/mcdi.c          |    2 +-
 drivers/net/sfc/mcdi.h          |    2 +-
 drivers/net/sfc/mcdi_mac.c      |    2 +-
 drivers/net/sfc/mcdi_pcol.h     |    2 +-
 drivers/net/sfc/mcdi_phy.c      |    2 +-
 drivers/net/sfc/mdio_10g.c      |    2 +-
 drivers/net/sfc/mdio_10g.h      |    2 +-
 drivers/net/sfc/mtd.c           |    2 +-
 drivers/net/sfc/net_driver.h    |    2 +-
 drivers/net/sfc/nic.c           |    2 +-
 drivers/net/sfc/nic.h           |    2 +-
 drivers/net/sfc/phy.h           |    2 +-
 drivers/net/sfc/qt202x_phy.c    |    2 +-
 drivers/net/sfc/regs.h          |    2 +-
 drivers/net/sfc/rx.c            |    2 +-
 drivers/net/sfc/selftest.c      |    2 +-
 drivers/net/sfc/selftest.h      |    2 +-
 drivers/net/sfc/siena.c         |    2 +-
 drivers/net/sfc/spi.h           |    2 +-
 drivers/net/sfc/tenxpress.c     |    2 +-
 drivers/net/sfc/tx.c            |    2 +-
 drivers/net/sfc/txc43128_phy.c  |    2 +-
 drivers/net/sfc/workarounds.h   |    2 +-
 30 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 35b7bc5..d563049 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2005-2009 Solarflare Communications Inc.
+ * Copyright 2005-2011 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index cbce62b..3d83a1f 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2009 Solarflare Communications Inc.
+ * Copyright 2006-2010 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 3e974b1..52fa661 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2009 Solarflare Communications Inc.
+ * Copyright 2006-2010 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 61ddd2c..87481a6 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2009 Solarflare Communications Inc.
+ * Copyright 2006-2010 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index 2dd16f0..b9cc846 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2007-2009 Solarflare Communications Inc.
+ * Copyright 2007-2010 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index b49e843..2c9ee5d 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2009 Solarflare Communications Inc.
+ * Copyright 2006-2010 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/io.h b/drivers/net/sfc/io.h
index 6da4ae2..dc45110 100644
--- a/drivers/net/sfc/io.h
+++ b/drivers/net/sfc/io.h
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2009 Solarflare Communications Inc.
+ * Copyright 2006-2010 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/mcdi.c b/drivers/net/sfc/mcdi.c
index 88e786b..8bba895 100644
--- a/drivers/net/sfc/mcdi.c
+++ b/drivers/net/sfc/mcdi.c
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2008-2009 Solarflare Communications Inc.
+ * Copyright 2008-2011 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/mcdi.h b/drivers/net/sfc/mcdi.h
index 9bac250..aced2a7 100644
--- a/drivers/net/sfc/mcdi.h
+++ b/drivers/net/sfc/mcdi.h
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2008-2009 Solarflare Communications Inc.
+ * Copyright 2008-2010 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/mcdi_mac.c b/drivers/net/sfc/mcdi_mac.c
index f88f4bf..33f7294 100644
--- a/drivers/net/sfc/mcdi_mac.c
+++ b/drivers/net/sfc/mcdi_mac.c
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2009 Solarflare Communications Inc.
+ * Copyright 2009-2010 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/mcdi_pcol.h b/drivers/net/sfc/mcdi_pcol.h
index 90359e6..b86a15f 100644
--- a/drivers/net/sfc/mcdi_pcol.h
+++ b/drivers/net/sfc/mcdi_pcol.h
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2009 Solarflare Communications Inc.
+ * Copyright 2009-2011 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/mcdi_phy.c b/drivers/net/sfc/mcdi_phy.c
index 0e97eed..ec3f740 100644
--- a/drivers/net/sfc/mcdi_phy.c
+++ b/drivers/net/sfc/mcdi_phy.c
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2009 Solarflare Communications Inc.
+ * Copyright 2009-2010 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 6e82e5b..19e68c2 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2006-2009 Solarflare Communications Inc.
+ * Copyright 2006-2011 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index 44c5dee..df07039 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2006-2009 Solarflare Communications Inc.
+ * Copyright 2006-2011 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/mtd.c b/drivers/net/sfc/mtd.c
index d386274..e646bfc 100644
--- a/drivers/net/sfc/mtd.c
+++ b/drivers/net/sfc/mtd.c
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2009 Solarflare Communications Inc.
+ * Copyright 2006-2010 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 5b001c1..9ea6cc2 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2005-2009 Solarflare Communications Inc.
+ * Copyright 2005-2011 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 1d0b8b6..fb25b87 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2009 Solarflare Communications Inc.
+ * Copyright 2006-2011 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/nic.h b/drivers/net/sfc/nic.h
index 17407ea..1daaee6 100644
--- a/drivers/net/sfc/nic.h
+++ b/drivers/net/sfc/nic.h
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2009 Solarflare Communications Inc.
+ * Copyright 2006-2011 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/phy.h b/drivers/net/sfc/phy.h
index 1dab609..b3b7947 100644
--- a/drivers/net/sfc/phy.h
+++ b/drivers/net/sfc/phy.h
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2007-2009 Solarflare Communications Inc.
+ * Copyright 2007-2010 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/qt202x_phy.c b/drivers/net/sfc/qt202x_phy.c
index ea3ae00..55f9092 100644
--- a/drivers/net/sfc/qt202x_phy.c
+++ b/drivers/net/sfc/qt202x_phy.c
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2006-2009 Solarflare Communications Inc.
+ * Copyright 2006-2010 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/regs.h b/drivers/net/sfc/regs.h
index 8227de6..cc2c86b 100644
--- a/drivers/net/sfc/regs.h
+++ b/drivers/net/sfc/regs.h
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2009 Solarflare Communications Inc.
+ * Copyright 2006-2010 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 81bec87..c0fdb59 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2005-2009 Solarflare Communications Inc.
+ * Copyright 2005-2011 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index f936892..a0f49b3 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2009 Solarflare Communications Inc.
+ * Copyright 2006-2010 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/selftest.h b/drivers/net/sfc/selftest.h
index aed495a..dba5456 100644
--- a/drivers/net/sfc/selftest.h
+++ b/drivers/net/sfc/selftest.h
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2008 Solarflare Communications Inc.
+ * Copyright 2006-2010 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index 07b59a8..8bd537e 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2009 Solarflare Communications Inc.
+ * Copyright 2006-2010 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/spi.h b/drivers/net/sfc/spi.h
index 879b7f6..71f2e3e 100644
--- a/drivers/net/sfc/spi.h
+++ b/drivers/net/sfc/spi.h
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005 Fen Systems Ltd.
- * Copyright 2006 Solarflare Communications Inc.
+ * Copyright 2006-2010 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 581911f..efdceb3 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2007-2009 Solarflare Communications Inc.
+ * Copyright 2007-2011 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 1a51653..1398019 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -1,7 +1,7 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2005-2009 Solarflare Communications Inc.
+ * Copyright 2005-2010 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/txc43128_phy.c b/drivers/net/sfc/txc43128_phy.c
index 4e2b48a..d9886ad 100644
--- a/drivers/net/sfc/txc43128_phy.c
+++ b/drivers/net/sfc/txc43128_phy.c
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2006-2010 Solarflare Communications Inc.
+ * Copyright 2006-2011 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index e0d6308..e4dd3a7 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2006-2009 Solarflare Communications Inc.
+ * Copyright 2006-2010 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
-- 
1.5.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

