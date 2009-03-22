From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next] Adding licensing to bnx2x_init_values.h
Date: Sun, 22 Mar 2009 13:14:54 +0200
Message-ID: <1237720494.10353.1.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3837 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752916AbZCVLQ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Mar 2009 07:16:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH net-next] Adding licensing to bnx2x_init_values.h

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_init_values.h |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_init_values.h b/drivers/net/bnx2x_init_values.h
index 6e18a55..1f22c9a 100644
--- a/drivers/net/bnx2x_init_values.h
+++ b/drivers/net/bnx2x_init_values.h
@@ -1,7 +1,23 @@
 #ifndef __BNX2X_INIT_VALUES_H__
 #define __BNX2X_INIT_VALUES_H__
 
-/* This array contains the list of operations needed to initialize the chip.
+/* bnx2x_init_values.h: Broadcom NX2 10G network driver.
+ *
+ * Copyright (c) 2007-2009 Broadcom Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, except as noted below.
+ *
+ * This file contains firmware data derived from proprietary unpublished
+ * source code, Copyright (c) 2007-2009 Broadcom Corporation.
+ *
+ * Permission is hereby granted for the distribution of this firmware data
+ * in hexadecimal or equivalent format, provided this copyright notice is
+ * accompanying it.
+ *
+ *
+ * This array contains the list of operations needed to initialize the chip.
  *
  * For each block in the chip there are three init stages:
  * common - HW used by both ports,
-- 
1.5.4.3




