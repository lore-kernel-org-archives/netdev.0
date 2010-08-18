From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: [PATCH 3/3] ibmveth: Driver version 1.04
Date: Wed, 18 Aug 2010 11:08:14 -0500
Message-ID: <20100818160813.GC29528@linux.vnet.ibm.com>
References: <20100818160515.GA29528@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Santiago Leon <santil@linux.vnet.ibm.com>,
	Brian King <brking@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:34384 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753783Ab0HRQIQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Aug 2010 12:08:16 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7IFr3tT008777
	for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 11:53:03 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7IG8FKQ449296
	for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 12:08:15 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7IG8E8f004602
	for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 10:08:14 -0600
Content-Disposition: inline
In-Reply-To: <20100818160515.GA29528@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bump driver version.

Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>
---
 drivers/net/ibmveth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: b/drivers/net/ibmveth.c
===================================================================
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -111,7 +111,7 @@ static struct proc_dir_entry *ibmveth_pr
 
 static const char ibmveth_driver_name[] = "ibmveth";
 static const char ibmveth_driver_string[] = "IBM i/pSeries Virtual Ethernet Driver";
-#define ibmveth_driver_version "1.03"
+#define ibmveth_driver_version "1.04"
 
 MODULE_AUTHOR("Santiago Leon <santil@us.ibm.com>");
 MODULE_DESCRIPTION("IBM i/pSeries Virtual Ethernet Driver");
