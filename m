From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next-2.6 PATCH 2/3] net: dcbnl: Fix misspellings
Date: Mon, 14 Mar 2011 12:01:08 -0700
Message-ID: <20110314190107.12070.90092.stgit@jf-dev1-dcblab>
References: <20110314190102.12070.21182.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: mark.d.rustad@intel.com, netdev@vger.kernel.org,
	shmulikr@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:31515 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753402Ab1CNTGf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 15:06:35 -0400
In-Reply-To: <20110314190102.12070.21182.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Fix a few spelling errors in dcbnl.h.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/linux/dcbnl.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index 97c90b9..eedf79b 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -26,13 +26,13 @@
 #define IEEE_8021QAZ_MAX_TCS	8
 
 #define IEEE_8021QAZ_TSA_STRICT		0
-#define IEEE_8021QAZ_TSA_CB_SHABER	1
+#define IEEE_8021QAZ_TSA_CB_SHAPER	1
 #define IEEE_8021QAZ_TSA_ETS		2
 #define IEEE_8021QAZ_TSA_VENDOR		255
 
 /* This structure contains the IEEE 802.1Qaz ETS managed object
  *
- * @willing: willing bit in ETS configuratin TLV
+ * @willing: willing bit in ETS configuration TLV
  * @ets_cap: indicates supported capacity of ets feature
  * @cbs: credit based shaper ets algorithm supported
  * @tc_tx_bw: tc tx bandwidth indexed by traffic class
@@ -92,7 +92,7 @@ struct ieee_pfc {
 #define CEE_DCBX_MAX_PRIO	8
 
 /**
- * struct cee_pg - CEE Prioity-Group managed object
+ * struct cee_pg - CEE Priority-Group managed object
  *
  * @willing: willing bit in the PG tlv
  * @error: error bit in the PG tlv

