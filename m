From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH 12/13] stmmac: update version to Jan_2016
Date: Fri, 25 Mar 2016 10:14:19 +0100
Message-ID: <1458897260-14104-13-git-send-email-alexandre.torgue@st.com>
References: <1458897260-14104-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Lars Persson <lars.persson@axis.com>
To: <netdev@vger.kernel.org>, <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:47559 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751540AbcCYJPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 05:15:21 -0400
In-Reply-To: <1458897260-14104-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch just updates the driver to the version fully
tested on STi platforms. This version is Jan_2016.

Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 317ce35..ff67506 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -24,7 +24,7 @@
 #define __STMMAC_H__
 
 #define STMMAC_RESOURCE_NAME   "stmmaceth"
-#define DRV_MODULE_VERSION	"Dec_2015"
+#define DRV_MODULE_VERSION	"Jan_2016"
 
 #include <linux/clk.h>
 #include <linux/stmmac.h>
-- 
1.9.1
