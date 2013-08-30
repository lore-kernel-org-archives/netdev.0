From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 16/16] sfc: Update copyright banners
Date: Fri, 30 Aug 2013 04:45:19 +0100
Message-ID: <1377834319.2552.42.camel@deadeye.wl.decadent.org.uk>
References: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35121 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103Ab3H3DpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 23:45:24 -0400
In-Reply-To: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the dates for files that have been added to in 2012-2013.
Drop the 'Solarstorm' brand name that's still lingering here.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/bitfield.h      |    4 ++--
 drivers/net/ethernet/sfc/efx.c           |    4 ++--
 drivers/net/ethernet/sfc/efx.h           |    4 ++--
 drivers/net/ethernet/sfc/enum.h          |    4 ++--
 drivers/net/ethernet/sfc/ethtool.c       |    4 ++--
 drivers/net/ethernet/sfc/falcon.c        |    4 ++--
 drivers/net/ethernet/sfc/falcon_boards.c |    4 ++--
 drivers/net/ethernet/sfc/farch.c         |    4 ++--
 drivers/net/ethernet/sfc/farch_regs.h    |    4 ++--
 drivers/net/ethernet/sfc/filter.h        |    4 ++--
 drivers/net/ethernet/sfc/io.h            |    4 ++--
 drivers/net/ethernet/sfc/mcdi.c          |    4 ++--
 drivers/net/ethernet/sfc/mcdi.h          |    4 ++--
 drivers/net/ethernet/sfc/mcdi_mon.c      |    4 ++--
 drivers/net/ethernet/sfc/mcdi_port.c     |    4 ++--
 drivers/net/ethernet/sfc/mdio_10g.c      |    2 +-
 drivers/net/ethernet/sfc/mdio_10g.h      |    2 +-
 drivers/net/ethernet/sfc/mtd.c           |    4 ++--
 drivers/net/ethernet/sfc/net_driver.h    |    4 ++--
 drivers/net/ethernet/sfc/nic.c           |    4 ++--
 drivers/net/ethernet/sfc/nic.h           |    4 ++--
 drivers/net/ethernet/sfc/phy.h           |    2 +-
 drivers/net/ethernet/sfc/ptp.c           |    4 ++--
 drivers/net/ethernet/sfc/qt202x_phy.c    |    4 ++--
 drivers/net/ethernet/sfc/rx.c            |    4 ++--
 drivers/net/ethernet/sfc/selftest.c      |    4 ++--
 drivers/net/ethernet/sfc/selftest.h      |    4 ++--
 drivers/net/ethernet/sfc/siena.c         |    4 ++--
 drivers/net/ethernet/sfc/siena_sriov.c   |    4 ++--
 drivers/net/ethernet/sfc/tenxpress.c     |    2 +-
 drivers/net/ethernet/sfc/tx.c            |    4 ++--
 drivers/net/ethernet/sfc/txc43128_phy.c  |    2 +-
 drivers/net/ethernet/sfc/vfdi.h          |    2 +-
 drivers/net/ethernet/sfc/workarounds.h   |    4 ++--
 34 files changed, 62 insertions(+), 62 deletions(-)

diff --git a/drivers/net/ethernet/sfc/bitfield.h b/drivers/net/ethernet/sfc/bitfield.h
index f45b0db..17d83f3 100644
--- a/drivers/net/ethernet/sfc/bitfield.h
+++ b/drivers/net/ethernet/sfc/bitfield.h
@@ -1,7 +1,7 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2009 Solarflare Communications Inc.
+ * Copyright 2006-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 5b66c5e..07c9bc4 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1,7 +1,7 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2005-2011 Solarflare Communications Inc.
+ * Copyright 2005-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 9de28f6..34d00f5 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -1,7 +1,7 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2010 Solarflare Communications Inc.
+ * Copyright 2006-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/enum.h b/drivers/net/ethernet/sfc/enum.h
index 8665921..7fdfee0 100644
--- a/drivers/net/ethernet/sfc/enum.h
+++ b/drivers/net/ethernet/sfc/enum.h
@@ -1,6 +1,6 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2007-2009 Solarflare Communications Inc.
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2007-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 78ddb48..5b471cf 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -1,7 +1,7 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2010 Solarflare Communications Inc.
+ * Copyright 2006-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index a7b30ddb..8685f99 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -1,7 +1,7 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2010 Solarflare Communications Inc.
+ * Copyright 2006-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/falcon_boards.c b/drivers/net/ethernet/sfc/falcon_boards.c
index ec1e99d..1736f4b 100644
--- a/drivers/net/ethernet/sfc/falcon_boards.c
+++ b/drivers/net/ethernet/sfc/falcon_boards.c
@@ -1,6 +1,6 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2007-2010 Solarflare Communications Inc.
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2007-2012 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index 65073aa..c0907d8 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -1,7 +1,7 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2011 Solarflare Communications Inc.
+ * Copyright 2006-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/farch_regs.h b/drivers/net/ethernet/sfc/farch_regs.h
index 491b103..7019a71 100644
--- a/drivers/net/ethernet/sfc/farch_regs.h
+++ b/drivers/net/ethernet/sfc/farch_regs.h
@@ -1,7 +1,7 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2010 Solarflare Communications Inc.
+ * Copyright 2006-2012 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/filter.h b/drivers/net/ethernet/sfc/filter.h
index e459e43..63c77a5 100644
--- a/drivers/net/ethernet/sfc/filter.h
+++ b/drivers/net/ethernet/sfc/filter.h
@@ -1,6 +1,6 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2005-2010 Solarflare Communications Inc.
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2005-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/io.h b/drivers/net/ethernet/sfc/io.h
index 416ee4a..96ce507 100644
--- a/drivers/net/ethernet/sfc/io.h
+++ b/drivers/net/ethernet/sfc/io.h
@@ -1,7 +1,7 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2010 Solarflare Communications Inc.
+ * Copyright 2006-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 272f201..128d7cd 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1,6 +1,6 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2008-2011 Solarflare Communications Inc.
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2008-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 5919aca..c34d0d4 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -1,6 +1,6 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2008-2010 Solarflare Communications Inc.
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2008-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/mcdi_mon.c b/drivers/net/ethernet/sfc/mcdi_mon.c
index e22d938..4cc5d95 100644
--- a/drivers/net/ethernet/sfc/mcdi_mon.c
+++ b/drivers/net/ethernet/sfc/mcdi_mon.c
@@ -1,6 +1,6 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2011 Solarflare Communications Inc.
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2011-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/mcdi_port.c b/drivers/net/ethernet/sfc/mcdi_port.c
index 03faf2f..8d33da6 100644
--- a/drivers/net/ethernet/sfc/mcdi_port.c
+++ b/drivers/net/ethernet/sfc/mcdi_port.c
@@ -1,6 +1,6 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2009-2010 Solarflare Communications Inc.
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2009-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/mdio_10g.c b/drivers/net/ethernet/sfc/mdio_10g.c
index 9acfd66..8ff954c 100644
--- a/drivers/net/ethernet/sfc/mdio_10g.c
+++ b/drivers/net/ethernet/sfc/mdio_10g.c
@@ -1,5 +1,5 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2006-2011 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
diff --git a/drivers/net/ethernet/sfc/mdio_10g.h b/drivers/net/ethernet/sfc/mdio_10g.h
index a97dbbd..16824fe 100644
--- a/drivers/net/ethernet/sfc/mdio_10g.h
+++ b/drivers/net/ethernet/sfc/mdio_10g.h
@@ -1,5 +1,5 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2006-2011 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
diff --git a/drivers/net/ethernet/sfc/mtd.c b/drivers/net/ethernet/sfc/mtd.c
index 8be9a69..a77a8bd 100644
--- a/drivers/net/ethernet/sfc/mtd.c
+++ b/drivers/net/ethernet/sfc/mtd.c
@@ -1,7 +1,7 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2010 Solarflare Communications Inc.
+ * Copyright 2006-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 753df15..b172ed1 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1,7 +1,7 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2005-2011 Solarflare Communications Inc.
+ * Copyright 2005-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index b9b1277..e8e01a1 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -1,7 +1,7 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2011 Solarflare Communications Inc.
+ * Copyright 2006-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 4bd53596..4b1e188 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -1,7 +1,7 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2011 Solarflare Communications Inc.
+ * Copyright 2006-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/phy.h b/drivers/net/ethernet/sfc/phy.h
index 4f6eb81..45eeb70 100644
--- a/drivers/net/ethernet/sfc/phy.h
+++ b/drivers/net/ethernet/sfc/phy.h
@@ -1,5 +1,5 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2007-2010 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index c60cabb..03acf57 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -1,6 +1,6 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2011 Solarflare Communications Inc.
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2011-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/qt202x_phy.c b/drivers/net/ethernet/sfc/qt202x_phy.c
index 326a286..efa3612 100644
--- a/drivers/net/ethernet/sfc/qt202x_phy.c
+++ b/drivers/net/ethernet/sfc/qt202x_phy.c
@@ -1,6 +1,6 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2006-2010 Solarflare Communications Inc.
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2006-2012 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 8c13dd8..4a59672 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -1,7 +1,7 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2005-2011 Solarflare Communications Inc.
+ * Copyright 2005-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index 716cff9..144bbff 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -1,7 +1,7 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2010 Solarflare Communications Inc.
+ * Copyright 2006-2012 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/selftest.h b/drivers/net/ethernet/sfc/selftest.h
index aed24b7..87698ae 100644
--- a/drivers/net/ethernet/sfc/selftest.h
+++ b/drivers/net/ethernet/sfc/selftest.h
@@ -1,7 +1,7 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2010 Solarflare Communications Inc.
+ * Copyright 2006-2012 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index e8eef63..d034bcd 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -1,7 +1,7 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2010 Solarflare Communications Inc.
+ * Copyright 2006-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index 4b8eef9..0c38f92 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -1,6 +1,6 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2010-2011 Solarflare Communications Inc.
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2010-2012 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/tenxpress.c b/drivers/net/ethernet/sfc/tenxpress.c
index d37cb50..2c90e6b 100644
--- a/drivers/net/ethernet/sfc/tenxpress.c
+++ b/drivers/net/ethernet/sfc/tenxpress.c
@@ -1,5 +1,5 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2007-2011 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 82075f9..2ac91c5 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -1,7 +1,7 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2005-2010 Solarflare Communications Inc.
+ * Copyright 2005-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
diff --git a/drivers/net/ethernet/sfc/txc43128_phy.c b/drivers/net/ethernet/sfc/txc43128_phy.c
index 29bb3f9..3d5ee32 100644
--- a/drivers/net/ethernet/sfc/txc43128_phy.c
+++ b/drivers/net/ethernet/sfc/txc43128_phy.c
@@ -1,5 +1,5 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2006-2011 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
diff --git a/drivers/net/ethernet/sfc/vfdi.h b/drivers/net/ethernet/sfc/vfdi.h
index 225557c..ae044f4 100644
--- a/drivers/net/ethernet/sfc/vfdi.h
+++ b/drivers/net/ethernet/sfc/vfdi.h
@@ -1,5 +1,5 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
+ * Driver for Solarflare network controllers and boards
  * Copyright 2010-2012 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
diff --git a/drivers/net/ethernet/sfc/workarounds.h b/drivers/net/ethernet/sfc/workarounds.h
index 8848ec0..2310b75 100644
--- a/drivers/net/ethernet/sfc/workarounds.h
+++ b/drivers/net/ethernet/sfc/workarounds.h
@@ -1,6 +1,6 @@
 /****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2006-2010 Solarflare Communications Inc.
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2006-2013 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
