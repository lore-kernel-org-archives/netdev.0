From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH 7/9] MAINTAINERS:Add maintainer for chelsio crypto driver
Date: Thu, 15 Jun 2017 12:43:45 +0530
Message-ID: <e76e20f2e2597574c77ba86c56ba4cc6636cbe81.1497506936.git.harsh@chelsio.com>
References: <cover.1497506936.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        netdev@vger.kernel.org, ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:15583 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752311AbdFOHOQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 03:14:16 -0400
In-Reply-To: <cover.1497506936.git.harsh@chelsio.com>
In-Reply-To: <cover.1497506936.git.harsh@chelsio.com>
References: <cover.1497506936.git.harsh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add myself as maintainer for chcr.

Signed-off-by: Harsh Jain <harsh@chelsio.com>
---
 MAINTAINERS | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 1f20176..504dc65 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3706,6 +3706,13 @@ S:	Supported
 F:	drivers/infiniband/hw/cxgb4/
 F:	include/uapi/rdma/cxgb4-abi.h
 
+CXGB4 CRYPTO DRIVER (chcr)
+M:	Harsh Jain <harsh@chelsio.com>
+L:	linux-crypto@vger.kernel.org
+W:	http://www.chelsio.com
+S:	Supported
+F:	drivers/crypto/chelsio
+
 CXGB4VF ETHERNET DRIVER (CXGB4VF)
 M:	Casey Leedom <leedom@chelsio.com>
 L:	netdev@vger.kernel.org
-- 
1.8.3.1
