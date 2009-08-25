From: Joe Perches <joe@perches.com>
Subject: [PATCH 7/9] s2io.c: fix spelling explaination
Date: Mon, 24 Aug 2009 20:29:46 -0700
Message-ID: <c2bb4f957ee38c91dc696d78922bbed16dcceedb.1251170438.git.joe@perches.com>
References: <cover.1251170438.git.joe@perches.com>
Cc: Anil Murthy <anil.murthy@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Ramkrishna Vepa <ram.vepa@neterion.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-next@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1358 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754349AbZHYDjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Aug 2009 23:39:06 -0400
In-Reply-To: <cover.1251170438.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/s2io.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 2805edd..4897f04 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -25,7 +25,7 @@
  * Christopher Hellwig	: Some more 2.6 specific issues in the driver.
  *
  * The module loadable parameters that are supported by the driver and a brief
- * explaination of all the variables.
+ * explanation of all the variables.
  *
  * rx_ring_num : This can be used to program the number of receive rings used
  * in the driver.
-- 
1.6.3.1.10.g659a0.dirty

