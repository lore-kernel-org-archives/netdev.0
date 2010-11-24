From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 8/17 v2] can: EG20T PCH: Change Copyright and
 module description
Date: Wed, 24 Nov 2010 16:36:30 +0900
Message-ID: <4CECC07E.40804__25611.4218071618$1290584245$gmane$org@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, margie.foster@intel.com
To: Wolfgang Grandegger <wg@grandegger.com>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>,
	Barry Song <21cnbao@gmail.com>,
	Samuel Ortiz <sameo@linux.inte
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:11418 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752040Ab0KXHgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 02:36:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, Copyright and module description are not formal.


Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 5b7a392..3a39786 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 1999 - 2010 Intel Corporation.
- * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
+ * Copyright (C) 2010 OKI SEMICONDUCTOR CO., LTD.
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -1312,6 +1312,6 @@ static void __exit pch_can_pci_exit(void)
 }
 module_exit(pch_can_pci_exit);
 -MODULE_DESCRIPTION("Controller Area Network Driver");
+MODULE_DESCRIPTION("Intel EG20T PCH CAN(Controller Area Network) Driver");
 MODULE_LICENSE("GPL v2");
 MODULE_VERSION("0.94");
-- 
1.6.0.6

