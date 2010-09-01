From: leitao@linux.vnet.ibm.com
Subject: [PATCH] MAINTAINERS: Add ehea driver as Supported
Date: Wed,  1 Sep 2010 15:23:23 -0300
Message-ID: <1283365403-20877-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: THEMANN@de.ibm.com, Breno Leitao <leitao@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:60811 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204Ab0IASX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 14:23:29 -0400
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp04.br.ibm.com (8.14.4/8.13.1) with ESMTP id o81IJNe6008620
	for <netdev@vger.kernel.org>; Wed, 1 Sep 2010 15:19:23 -0300
Received: from d24av03.br.ibm.com (d24av03.br.ibm.com [9.8.31.95])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o81IT1XJ897154
	for <netdev@vger.kernel.org>; Wed, 1 Sep 2010 15:29:02 -0300
Received: from d24av03.br.ibm.com (loopback [127.0.0.1])
	by d24av03.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o81INMbp029119
	for <netdev@vger.kernel.org>; Wed, 1 Sep 2010 15:23:23 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change just add the IBM eHEA 10Gb network drivers as supported.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 MAINTAINERS |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index c36f5d7..9f40d29 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2201,6 +2201,12 @@ L:	linux-rdma@vger.kernel.org
 S:	Supported
 F:	drivers/infiniband/hw/ehca/
 
+EHEA (IBM pSeries eHEA 10Gb ethernet adapter) DRIVER
+M:	Breno Leitao <leitao@linux.vnet.ibm.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/ehea/
+
 EMBEDDED LINUX
 M:	Paul Gortmaker <paul.gortmaker@windriver.com>
 M:	Matt Mackall <mpm@selenic.com>
-- 
1.6.0.4

