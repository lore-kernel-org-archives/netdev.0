From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH v3 17/17] stmmac: update version to Oct_2015
Date: Mon, 29 Feb 2016 14:27:43 +0100
Message-ID: <1456752463-27128-18-git-send-email-alexandre.torgue@st.com>
References: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <peppe.cavallaro@st.com>, <fabrice.gasnier@st.com>,
	<maxime.coquelin@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:45944 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754194AbcB2N3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 08:29:10 -0500
Received: from pps.filterd (m0046661.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u1TDRpUW019379
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:29:09 +0100
Received: from beta.dmz-ap.st.com (beta.dmz-ap.st.com [138.198.100.35])
	by mx08-00178001.pphosted.com with ESMTP id 21b3jgaqgp-1
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:29:09 +0100
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id C635823
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:29:04 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas1.st.com [10.80.176.8])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 6C01EF7
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:29:03 +0000 (GMT)
In-Reply-To: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>

This patch just updates the driver to the version fully
tested on STi platforms. This version is Oct_2015.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index d6c244f..8bbab97 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -24,7 +24,7 @@
 #define __STMMAC_H__
 
 #define STMMAC_RESOURCE_NAME   "stmmaceth"
-#define DRV_MODULE_VERSION	"March_2013"
+#define DRV_MODULE_VERSION	"Oct_2015"
 
 #include <linux/clk.h>
 #include <linux/stmmac.h>
-- 
1.9.1
